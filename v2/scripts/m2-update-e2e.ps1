<#
.SYNOPSIS
    The update end to end test on a real PC: signed manifests (the real release key), the
    real service, a real tunnel, a real server. Nobody has to answer anything; everything
    is written to a log file.

.DESCRIPTION
    Order of work: m2-update-e2e-prepare.ps1, then m2-update-e2e-sign.ps1 (the owner of the
    release key runs that one), then this, from an ADMINISTRATOR PowerShell, with the v1 app
    closed (Disconnect and Quit): the test connects with the Charon v2 service, and while
    it runs the PC has no other tunnel. About 20 minutes. When it says DONE the v1 app can
    be started again.

    What it does to the PC, and takes back at the end (also when it breaks):
      * a small web server on 127.0.0.1 serves the signed manifests and the test files
      * the service is told to look there for updates (an Environment value on the service)
      * xray.exe of the program folder is replaced by Xray 26.10.21, the core to update from
      * S1  core update: a real newer core (26.10.31). The tunnel is up when Apply now is
            pressed, so the swap must wait, and run by itself after the disconnect, pass
            the config check and the handshake against the real server. Then a connect with
            the new core, a replay of the old manifest (must be refused), the one tap
            rollback, and a restart of the service (the version must come from the binary)
      * S2  a core that takes the config but never opens its SOCKS port: the handshake
            check fails and the old core must come back by itself
      * S3  a core that rejects the config: refused before any swap
      * S4  the app update to 0.1.1: the installer is downloaded while connected, and
            started the way the window starts it. Then 0.1.1 must be what runs
      * at the end the 0.1.0 installer is run over it, the Environment value and the
        update state (sequence number, staged files) are removed, the service is started
    The tunnel is disconnected before every step that stops the service. If the internet
    stays blocked after DONE (a Charon filter that stayed): "<program folder>\charon-release.exe".
#>
param(
    [string]$Dir = (Join-Path $PSScriptRoot '..\dist-e2e'),
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$LogDir = ([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\charon-essential\charon-m2-test\logs'))),
    [string]$WfpCheck = ([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\charon-essential\charon-m2-test\charon-wfpcheck.exe'))),
    [string]$ProgramDir = "$env:ProgramFiles\Charon",
    [string]$DataDir = "$env:ProgramData\Charon",
    [int]$Port = 8765
)
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Continue'
$Svc = 'charon-service'
$Sc = Join-Path $env:SystemRoot 'System32\sc.exe'
$SvcKey = "HKLM:\SYSTEM\CurrentControlSet\Services\$Svc"
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path (Join-Path $LogDir "update-e2e-$stamp.log") -Force | Out-Null

$results = New-Object System.Collections.Generic.List[string]
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    $l = '{0}  {1}{2}' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $name, $(if ($detail) { "  ($detail)" } else { '' })
    Write-Host $l -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $results.Add($l)
}
function Info([string]$text) { Write-Host "    $text" }
function Has($lines, [string]$pattern) { return (($lines -join "`n") -match $pattern) }
function Line($lines, [string]$tag) { return ($lines | Where-Object { $_ -match "^E2E $tag( |$)" } | Select-Object -Last 1) }

function State { return (Get-Service $Svc -ErrorAction SilentlyContinue).Status }
function WaitFor([string]$want, [int]$seconds = 30) {
    $t0 = Get-Date
    while (((Get-Date) - $t0).TotalSeconds -lt $seconds) {
        if ("$(State)" -eq $want) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}
function Sha([string]$path) {
    if (Test-Path $path) { return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant() }
    return 'missing'
}
function Wfp { if (Test-Path $WfpCheck) { return "$(& $WfpCheck list 2>&1 | Select-Object -First 1)" } else { return 'charon-wfpcheck.exe not found' } }
function WfpCount { if ((Wfp) -match '(\d+)\s*$') { return [int]$Matches[1] } else { return -1 } }

# The test of the app talks to the real service (m2_probe_test.dart). The lines it prints
# start with "Shell:"; these come back without it.
function Probe([string]$command, [int]$timeout = 170) {
    Write-Host "  > probe: $command" -ForegroundColor DarkCyan
    $job = Start-Job -ScriptBlock {
        param($app, $flutter, $c)
        $env:CHARON_PROBE = $c
        Set-Location $app
        & $flutter test test/m2_probe_test.dart 2>&1
    } -ArgumentList $App, $Flutter, $command
    if (Wait-Job $job -Timeout $timeout) { $out = Receive-Job $job } else { Stop-Job $job; $out = @('Shell: PROBE TIMEOUT') }
    Remove-Job $job -Force
    $lines = @($out | ForEach-Object { "$_" } | Where-Object { $_ -match '^Shell:' } | ForEach-Object { $_ -replace '^Shell:\s?', '' })
    $lines | ForEach-Object { Info $_ }
    return $lines
}

function StopSvc { Stop-Service $Svc -Force -ErrorAction SilentlyContinue; [void](WaitFor 'Stopped' 30) }
function StartSvc { Start-Service $Svc -ErrorAction SilentlyContinue; [void](WaitFor 'Running' 30); Start-Sleep -Seconds 4 }
function Versions {
    $h = Probe 'hello'
    if (($h -join ' ') -match 'service ([\d.]+), xray ([\d.]+)') { return @{ service = $Matches[1]; xray = $Matches[2] } }
    return @{ service = ''; xray = '' }
}
function ResetUpdateState { Remove-Item (Join-Path $DataDir 'staging\*') -Recurse -Force -ErrorAction SilentlyContinue }
function SetManifestUrl($value) {
    if ($value) { Set-ItemProperty -Path $SvcKey -Name Environment -Value $value -Type MultiString }
    else { Remove-ItemProperty -Path $SvcKey -Name Environment -ErrorAction SilentlyContinue }
}

$web = $null
$originalEnv = $null
$ranStart = $false
try {
    Write-Host '=== 0  before' -ForegroundColor Cyan
    $Dir = (Resolve-Path $Dir).Path
    $App = (Resolve-Path $App).Path
    $serve = Join-Path $Dir 'serve'
    $mf = Join-Path $Dir 'manifests'
    $startCore = Join-Path $Dir 'start\xray.exe'
    $realCore = Join-Path $serve 'xray-windows-amd64.exe'
    $installer010 = Join-Path $serve 'Charon-Setup-0.1.0.exe'
    foreach ($m in 'm10', 'm11', 'm12', 'm13', 'm14') {
        if (-not (Test-Path "$mf\$m.json.sig")) { throw "$mf\$m.json.sig is missing: run m2-update-e2e-sign.ps1 first. Nothing was changed." }
    }
    foreach ($f in $startCore, $realCore, $installer010) { if (-not (Test-Path $f)) { throw "$f is missing: run m2-update-e2e-prepare.ps1 first. Nothing was changed." } }
    if (@(Get-Process -Name CharonVPN -ErrorAction SilentlyContinue).Count -gt 0) { throw 'The v1 app (CharonVPN) is running. Disconnect and Quit it first. Nothing was changed.' }
    if ("$(State)" -ne 'Running') { throw "The service is $(State), the test needs it installed and running. Nothing was changed." }
    $py = (Get-Command python -ErrorAction Stop).Source
    $pinned = Sha $realCore
    $startSha = Sha $startCore
    Info "service before: $(State), xray.exe in the program folder: $((Sha "$ProgramDir\xray.exe").Substring(0, 12)), pinned core $($pinned.Substring(0, 12)), start core $($startSha.Substring(0, 12))"
    Info (Wfp)
    $originalEnv = (Get-ItemProperty -Path $SvcKey -Name Environment -ErrorAction SilentlyContinue).Environment

    Write-Host ''
    Write-Host '=== setup: web server, update address, start core' -ForegroundColor Cyan
    Copy-Item "$mf\m10.json" "$serve\manifest.json" -Force
    Copy-Item "$mf\m10.json.sig" "$serve\manifest.json.sig" -Force
    $web = Start-Process -FilePath $py -ArgumentList @('-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', "`"$serve`"") -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 2
    $got = try { (Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port/manifest.json" -TimeoutSec 10).StatusCode } catch { 0 }
    Check 'the test web server answers' ($got -eq 200) "HTTP $got"
    $ranStart = $true
    StopSvc
    Copy-Item $startCore "$ProgramDir\xray.exe" -Force
    ResetUpdateState
    SetManifestUrl @("CHARON_MANIFEST_BASE_URL=http://127.0.0.1:$Port")
    StartSvc
    $v = Versions
    Check 'the service reports the core the binary says (26.10.21), not the compiled in 26.10.31' ($v.xray -eq '26.10.21') "service $($v.service), xray $($v.xray)"
    if ($v.xray -ne '26.10.21') { throw 'The test cannot start: the service did not come up with the start core.' }

    # ---------------------------------------------------------------- S1
    Write-Host ''
    Write-Host '=== S1  a real newer core, with the tunnel up when Apply now is pressed' -ForegroundColor Cyan
    $r = Probe 'updatecore' 480
    Check 'S1 the tunnel came up with the start core' (Has $r 'E2E up=True') (Line $r 'up=\w+')
    if (-not (Has $r 'E2E up=True')) {
        Info 'what the service says about it:'
        [void](Probe 'logs 60')
        throw 'The tunnel did not come up with the start core (Xray 26.10.21), so the rest cannot run. Everything is put back now.'
    }
    Check 'S1 the update was found and downloaded while connected (READY, 26.10.21 to 26.10.31)' (Has (Line $r 'core-before-apply') 'stage=UPDATE_READY.*current=26.10.21 new=26.10.31') (Line $r 'core-before-apply')
    Check 'S1 Apply now with the tunnel up is queued, not applied' (Has (Line $r 'apply-while-up') 'stage=UPDATE_QUEUED') (Line $r 'apply-while-up')
    Check 'S1 after the disconnect the swap ran by itself and succeeded' (Has (Line $r 'core-end') 'stage=UPDATE_UPDATED.*current=26.10.31') (Line $r 'core-end')
    Check 'S1 xray.exe in the program folder is the new core' ((Sha "$ProgramDir\xray.exe") -eq $pinned)
    Check 'S1 xray.prev.exe is the old core (for the rollback)' ((Sha "$ProgramDir\xray.prev.exe") -eq $startSha)
    $v = Versions
    Check 'S1 the service reports the new core at once, with no restart' ($v.xray -eq '26.10.31') $v.xray
    $logs = Probe 'logs 80'
    Check 'S1 service log: the new core took every saved config (xray run -test)' (Has $logs 'takes all \d+ saved configs')
    Check 'S1 service log: the new core passed the handshake against the real server' (Has $logs 'passed the handshake')
    $c = Probe 'connect' 120
    Check 'S1 a real connect with the new core comes up' (Has $c 'phase=PHASE_UP')
    [void](Probe 'disconnect' 90)
    $rp = Probe 'updatecheck'
    Check 'S1 the manifest that was just applied is refused as a replay' (Has $rp 'error\.update\.rollback') (($rp | Select-Object -First 2) -join ' | ')
    $rb = Probe 'rollbackcore'
    Check 'S1 the one tap rollback brings the old core back' (Has (Line $rb 'rollback') 'stage=UPDATE_ROLLED_BACK.*current=26.10.21') (Line $rb 'rollback')
    Check 'S1 xray.exe is the old core again' ((Sha "$ProgramDir\xray.exe") -eq $startSha)
    StopSvc; StartSvc
    $v = Versions
    Check 'S1 after a restart the service still reports the core of the binary (26.10.21)' ($v.xray -eq '26.10.21') $v.xray

    # ---------------------------------------------------------------- S2
    Write-Host ''
    Write-Host '=== S2  a core that never opens its SOCKS port: the handshake fails, the old core comes back' -ForegroundColor Cyan
    Copy-Item "$mf\m11.json" "$serve\manifest.json" -Force
    Copy-Item "$mf\m11.json.sig" "$serve\manifest.json.sig" -Force
    $r = Probe 'updatecore' 480
    Check 'S2 the update was downloaded and Apply now was queued' ((Has (Line $r 'core-before-apply') 'stage=UPDATE_READY.*new=26.10.40') -and (Has (Line $r 'apply-while-up') 'stage=UPDATE_QUEUED')) (Line $r 'apply-while-up')
    Check 'S2 the swap was rolled back by itself, with the handshake as the reason' (Has (Line $r 'core-end') 'stage=UPDATE_ROLLED_BACK.*failure=error\.update\.handshake_failed.*current=26.10.21') (Line $r 'core-end')
    Check 'S2 xray.exe is the old core again' ((Sha "$ProgramDir\xray.exe") -eq $startSha)
    $logs = Probe 'logs 80'
    Check 'S2 service log: the config check passed, the handshake check failed' ((Has $logs 'takes all \d+ saved configs') -and (Has $logs 'failed the handshake'))
    $rp = Probe 'updatecheck'
    Check 'S2 the sequence number was not used up (the same release is offered again)' (Has $rp 'CORE stage=UPDATE_AVAILABLE.*new=26.10.40') (Line $rp 'check')

    # ---------------------------------------------------------------- S3
    Write-Host ''
    Write-Host '=== S3  a core that rejects the config: refused before any swap' -ForegroundColor Cyan
    Copy-Item "$mf\m12.json" "$serve\manifest.json" -Force
    Copy-Item "$mf\m12.json.sig" "$serve\manifest.json.sig" -Force
    $r = Probe 'updatecore' 480
    Check 'S3 the update was downloaded and Apply now was queued' ((Has (Line $r 'core-before-apply') 'stage=UPDATE_READY.*new=26.10.41') -and (Has (Line $r 'apply-while-up') 'stage=UPDATE_QUEUED')) (Line $r 'apply-while-up')
    Check 'S3 the config check refused the core' (Has (Line $r 'core-end') 'stage=UPDATE_CANNOT_CHECK.*failure=error\.update\.config_test_failed') (Line $r 'core-end')
    Check 'S3 xray.exe was never touched' ((Sha "$ProgramDir\xray.exe") -eq $startSha)

    # ---------------------------------------------------------------- S4
    Write-Host ''
    Write-Host '=== S4  the app update to 0.1.1, started the way the window starts it' -ForegroundColor Cyan
    Copy-Item "$mf\m13.json" "$serve\manifest.json" -Force
    Copy-Item "$mf\m13.json.sig" "$serve\manifest.json.sig" -Force
    $r = Probe 'updateapp' 480
    Check 'S4 the installer was found and downloaded while connected (READY, 0.1.0 to 0.1.1)' (Has (Line $r 'app-before-apply') 'stage=UPDATE_READY.*current=0\.1\.0 new=0\.1\.1') (Line $r 'app-before-apply')
    Check 'S4 Apply answered APPLYING with the staged installer' (Has (Line $r 'apply-app') 'stage=UPDATE_APPLYING') (Line $r 'apply-app')
    Check 'S4 the installer is directly inside the staging folder (the window would start it)' (Has $r 'E2E installer-in-staging=True')
    Check 'S4 the installer ran and exited 0' (Has $r 'E2E installer exit=0') (Line $r 'installer')
    [void](WaitFor 'Running' 40); Start-Sleep -Seconds 4
    $v = Versions
    Check 'S4 the service that runs now is 0.1.1 (the version is stamped into the release)' ($v.service -eq '0.1.1') "service $($v.service), xray $($v.xray)"
    Check 'S4 xray.exe is the core of the installer (pinned 26.10.31)' ((Sha "$ProgramDir\xray.exe") -eq $pinned)
    Copy-Item "$mf\m14.json" "$serve\manifest.json" -Force
    Copy-Item "$mf\m14.json.sig" "$serve\manifest.json.sig" -Force
    $rp = Probe 'updatecheck'
    Check 'S4 after the update nothing is offered (app is up to date at 0.1.1)' (Has $rp 'APP stage=UPDATE_UP_TO_DATE.*current=0\.1\.1') (Line $rp 'check')
}
catch {
    Write-Host "ABORTED: $_" -ForegroundColor Red
    $results.Add("ABORT  $_")
}
finally {
    Write-Host ''
    Write-Host '=== putting things back (always)' -ForegroundColor Cyan
    if ($ranStart) {
        if ("$(State)" -eq 'Running') { [void](Probe 'disconnect' 90) }   # the tunnel is down before the service stops
        if ($web) { Stop-Process -Id $web.Id -Force -ErrorAction SilentlyContinue }
        StopSvc
        if ($originalEnv) { SetManifestUrl $originalEnv } else { SetManifestUrl $null }
        ResetUpdateState
        Info 'the 0.1.0 installer goes over whatever is there now'
        $log = Join-Path $LogDir "update-e2e-$stamp-restore.inno.log"
        $p = Start-Process -FilePath $installer010 -ArgumentList ('/SILENT /SUPPRESSMSGBOXES /NORESTART /LOG="{0}"' -f $log) -PassThru
        if (-not $p.WaitForExit(300000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; Info 'the installer did not finish in 5 minutes' }
        else { Info "installer exit code: $($p.ExitCode)" }
        if ("$(State)" -ne 'Running') { StartSvc }
        # The installer does not touch xray.prev.exe, so the core the test swapped out would
        # stay as a "previous core" that was never run here, and the rollback would offer it.
        Remove-Item "$ProgramDir\xray.prev.exe" -Force -ErrorAction SilentlyContinue
        $v = Versions
        Check 'restore: the service is 0.1.0 with the pinned core again' ($v.service -eq '0.1.0' -and $v.xray -eq '26.10.31') "service $($v.service), xray $($v.xray)"
        Check 'restore: xray.exe is the pinned core' ((Sha "$ProgramDir\xray.exe") -eq $pinned)
        Check 'restore: no update address and no update state left behind' ($null -eq (Get-ItemProperty -Path $SvcKey -Name Environment -ErrorAction SilentlyContinue).Environment -or $originalEnv)
        Check 'restore: no Charon filter is left' ((WfpCount) -eq 0) (Wfp)
        if ((WfpCount) -gt 0) { Write-Host '    Charon filters are still there. If the internet is blocked: "<program folder>\charon-release.exe" removes them.' -ForegroundColor Yellow }
    }
    Write-Host ''
    Write-Host '=== SUMMARY'
    $results | ForEach-Object { Write-Host $_ }
    $fails = @($results | Where-Object { $_ -notmatch '^PASS' }).Count
    Write-Host ''
    Write-Host ("{0} checks, {1} not passed." -f $results.Count, $fails) -ForegroundColor $(if ($fails -eq 0) { 'Green' } else { 'Red' })
    Write-Host "DONE. You can start the v1 app again. Log: $LogDir\update-e2e-$stamp.log" -ForegroundColor Cyan
    Stop-Transcript | Out-Null
}
