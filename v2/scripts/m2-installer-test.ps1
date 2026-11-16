<#
.SYNOPSIS
    The real test of the Charon installer, from the first install to the uninstall,
    without anybody at the keyboard. Everything is written to a log file.

.DESCRIPTION
    Run it from an ADMINISTRATOR PowerShell. It stops and replaces the Charon v2 service and
    starts no tunnel, so the v1 app may stay open (the first run was done with it closed, to
    be safe). The script needs no answers: it takes about five minutes.

      1  install over what is there (the first real install)
      2  install again while the service runs and the window is open (what the Install
         button of the Updates screen does: the same silent arguments)
      3  uninstall
      4  install again, and leave it installed

    After each install: the files, their hashes, the service settings, the folder ACLs,
    the pipe owner, the shortcut and the uninstall entry are checked, and a Hello over the
    pipe shows that the installed service runs the bundled Xray. Build the installer first
    with scripts/package-release.ps1. The log goes to LogDir (a transcript, plus the log
    of every installer run).
#>
param(
    [string]$Installer = (Join-Path $PSScriptRoot '..\dist\Charon-Setup-0.1.0.exe'),
    [string]$Xray = (Join-Path $PSScriptRoot '..\dist\xray-windows-amd64.exe'),
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$LogDir = 'D:\charon-m2-test\logs',
    [string]$WfpCheck = 'D:\charon-m2-test\charon-wfpcheck.exe',
    # What is put back when the test breaks before the last install: the stage of the M2 tests.
    [string]$Restore = 'D:\charon-m2-test\stage',
    [string]$ProgramDir = "$env:ProgramFiles\Charon",
    [string]$DataDir = "$env:ProgramData\Charon",
    # Which of the four steps run, for example '34' to repeat only the uninstall and the install after it.
    [string]$Phases = '1234',
    # Skip the Hello over the pipe (it runs flutter test and takes a minute or two each).
    [switch]$SkipProbe
)
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Continue'
$Svc = 'charon-service'
$Sc = Join-Path $env:SystemRoot 'System32\sc.exe'
# wintun.dll 0.14.1 amd64, the pin of package-release.ps1 (the zip is pinned there).
$WintunDllSha256 = 'e5da8447dc2c320edc0fc52fa01885c103de8c118481f683643cacc3220dafce'
$AppKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C4A20700-8B4E-4D19-9A31-0000C4A20700}_is1'
$Shortcut = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Charon.lnk'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path (Join-Path $LogDir "installer-test-$stamp.log") -Force | Out-Null

$results = New-Object System.Collections.Generic.List[string]
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    $l = '{0}  {1}{2}' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $name, $(if ($detail) { "  ($detail)" } else { '' })
    Write-Host $l -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $results.Add($l)
}
function Info([string]$text) { Write-Host "    $text" }

function State { return (Get-Service $Svc -ErrorAction SilentlyContinue).Status }
function WaitFor([string]$want, [int]$seconds = 25) {
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

# Same as the probe of m2-repair-test.ps1: the test of the app talks to the real service.
function Probe([string]$command, [int]$timeout = 170) {
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

# Runs the installer with the arguments of the Updates screen (+ a log). Returns the exit code.
function RunSetup([string]$label) {
    $log = Join-Path $LogDir "installer-test-$stamp-$label.inno.log"
    $p = Start-Process -FilePath $Installer -ArgumentList ('/SILENT /SUPPRESSMSGBOXES /NORESTART /LOG="{0}"' -f $log) -PassThru
    if (-not $p.WaitForExit(300000)) {
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        Check "$label installer finished in 5 minutes" $false 'killed'
        return @{ code = -1; log = $log }
    }
    return @{ code = $p.ExitCode; log = $log }
}

# The exit code of every program the installer ran (install.ps1, uninstall.ps1) is in its log.
# Inno does not stop on a non zero one, so only the log tells.
function CheckInnoLog([string]$label, $run) {
    Check "$label installer exit code 0" ($run.code -eq 0) "exit $($run.code)"
    if (-not (Test-Path $run.log)) { Check "$label installer wrote its log" $false; return }
    $codes = @(Select-String -Path $run.log -Pattern 'Process exit code: (-?\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value })
    Check "$label every program the installer ran exited 0" (($codes.Count -gt 0) -and (@($codes | Where-Object { $_ -ne '0' }).Count -eq 0)) ("exit codes: " + ($codes -join ','))
    $bad = @(Select-String -Path $run.log -Pattern '(?i)exception|failed' | ForEach-Object { $_.Line.Trim() })
    $detail = ($bad | Select-Object -First 3) -join ' | '
    Check "$label the installer log has no exception or failure" ($bad.Count -eq 0) $detail
}

function Rights([string]$path, [string]$sid) {
    $r = @()
    foreach ($ace in (Get-Acl $path).Access) {
        try {
            if ($ace.AccessControlType -eq 'Allow' -and $ace.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid) { $r += "$($ace.FileSystemRights)" }
        } catch { }
    }
    return ($r -join ' ; ')
}

function VerifyInstall([string]$label, [bool]$probe) {
    Write-Host "--- what the install left ($label)" -ForegroundColor Cyan
    foreach ($f in 'charon.exe', 'charon-service.exe', 'charon-release.exe', 'xray.exe', 'wintun.dll', 'install.ps1', 'uninstall.ps1', 'unins000.exe', 'flutter_windows.dll') {
        Check "$label file $f" (Test-Path (Join-Path $ProgramDir $f))
    }
    Check "$label the window's data folder" (Test-Path (Join-Path $ProgramDir 'data'))
    Check "$label xray.exe is the pinned core" ((Sha (Join-Path $ProgramDir 'xray.exe')) -eq (Sha $Xray)) (Sha $Xray).Substring(0, 12)
    Check "$label wintun.dll is the pinned 0.14.1" ((Sha (Join-Path $ProgramDir 'wintun.dll')) -eq $WintunDllSha256)

    $s = Get-CimInstance Win32_Service -Filter "Name='$Svc'"
    $path = if ($s) { "$($s.PathName)".Trim('"') } else { '' }
    Check "$label the service is registered, automatic, LocalSystem, right file" ($s -and $s.StartMode -eq 'Auto' -and $s.StartName -eq 'LocalSystem' -and $path -ieq (Join-Path $ProgramDir 'charon-service.exe')) "$($s.StartMode) $($s.StartName) $path"
    $deps = @((Get-Service $Svc -ErrorAction SilentlyContinue).ServicesDependedOn | ForEach-Object { $_.Name })
    Check "$label the service waits for Tcpip and Nsi" (($deps -contains 'Tcpip') -and ($deps -contains 'Nsi')) ($deps -join ',')
    Check "$label the service is running" (WaitFor 'Running') "$(State)"

    $owner = ''
    if (Test-Path (Join-Path $DataDir 'owner.sid')) { $owner = (Get-Content (Join-Path $DataDir 'owner.sid') -Raw).Trim() }
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    Check "$label the pipe owner is the installing user" ($owner -eq $me) $owner
    $sd = (& $Sc sdshow $Svc) -join ''
    $want = "(A;;CCLCRPRC;;;$me)"
    Check "$label the installing user may start the service but not stop it" ($sd.Contains($want)) $sd

    $pr = Rights $ProgramDir 'S-1-5-32-545'
    Check "$label program folder: Users read and execute only" (($pr -match 'ReadAndExecute') -and ($pr -notmatch 'Write|Modify|FullControl|Delete')) $pr
    $dr = (Rights $DataDir 'S-1-5-32-545') + (Rights $DataDir 'S-1-1-0') + (Rights $DataDir 'S-1-5-11')
    Check "$label data folder: no entry for Users, Everyone, Authenticated Users" ($dr -eq '') $dr
    Check "$label Start menu shortcut" (Test-Path $Shortcut)
    $reg = Get-ItemProperty $AppKey -ErrorAction SilentlyContinue
    Check "$label uninstall entry" ($null -ne $reg -and $reg.UninstallString) "$($reg.DisplayVersion)"
    Info (Wfp)

    if ($probe -and -not $SkipProbe) {
        $h = Probe 'hello'
        Check "$label Hello: the service answers and runs the bundled Xray" (($h -join ' ') -match 'xray 26\.10\.31' -and ($h -join ' ') -match 'status:') ($h | Select-Object -First 1)
    }
}

try {
    Write-Host '=== 0  before' -ForegroundColor Cyan
    if (-not (Test-Path $Installer)) { throw "No installer at $Installer. Run scripts/package-release.ps1 first." }
    $Installer = (Resolve-Path $Installer).Path
    $Xray = (Resolve-Path $Xray).Path
    $App = (Resolve-Path $App).Path
    # The test touches only the Charon v2 service and starts no tunnel, so the v1 app may stay open.
    Info ("v1 app (CharonVPN) running: " + (@(Get-Process -Name CharonVPN -ErrorAction SilentlyContinue).Count -gt 0))
    Info "installer: $Installer ($((Get-Item $Installer).Length) bytes)"
    Info "service before: $(State)"
    Info (Wfp)
    $startedFirst = (Get-Process charon-service -ErrorAction SilentlyContinue | Select-Object -First 1).StartTime

    if ($Phases.Contains('1')) {
    Write-Host ''
    Write-Host '=== 1  install over what is there' -ForegroundColor Cyan
    $r1 = RunSetup 'install1'
    CheckInnoLog 'install1' $r1
    VerifyInstall 'install1' $false
    $startedAfter1 = (Get-Process charon-service -ErrorAction SilentlyContinue | Select-Object -First 1).StartTime
    if ($startedFirst) { Check 'install1 the old service was stopped and the new one started' ($startedAfter1 -gt $startedFirst) "$startedFirst -> $startedAfter1" }
    }

    if ($Phases.Contains('2')) {
    Write-Host ''
    Write-Host '=== 2  update: the service runs, the window is open' -ForegroundColor Cyan
    $dataBefore = @(Get-ChildItem $DataDir -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName.Substring($DataDir.Length) })
    $ownerBefore = Get-Content (Join-Path $DataDir 'owner.sid') -Raw
    $win = Start-Process -FilePath (Join-Path $ProgramDir 'charon.exe') -PassThru
    Start-Sleep -Seconds 8
    Check 'update the window is open before the update' (-not $win.HasExited)
    $t1 = (Get-Process charon-service -ErrorAction SilentlyContinue | Select-Object -First 1).StartTime
    $r2 = RunSetup 'update'
    CheckInnoLog 'update' $r2
    $t2 = (Get-Process charon-service -ErrorAction SilentlyContinue | Select-Object -First 1).StartTime
    Check 'update the running service was stopped and started again' ($t1 -and $t2 -and $t2 -gt $t1) "$t1 -> $t2"
    Check 'update the open window was closed by the installer' (@(Get-Process -Name charon -ErrorAction SilentlyContinue).Count -eq 0)
    $dataAfter = @(Get-ChildItem $DataDir -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName.Substring($DataDir.Length) })
    $lost = @($dataBefore | Where-Object { $dataAfter -notcontains $_ })
    Check 'update the saved data survived' ($lost.Count -eq 0) ("lost: " + ($lost -join ','))
    Check 'update the pipe owner is unchanged' ((Get-Content (Join-Path $DataDir 'owner.sid') -Raw) -eq $ownerBefore)
    VerifyInstall 'update' $true
    }

    if ($Phases.Contains('3')) {
    Write-Host ''
    Write-Host '=== 3  uninstall' -ForegroundColor Cyan
    $un = "$((Get-ItemProperty $AppKey -ErrorAction SilentlyContinue).UninstallString)".Trim('"')
    if (-not $un -or -not (Test-Path $un)) { throw 'No uninstaller found, so the uninstall cannot be tested.' }
    $ulog = Join-Path $LogDir "installer-test-$stamp-uninstall.inno.log"
    $p = Start-Process -FilePath $un -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /LOG="{0}"' -f $ulog) -PassThru
    [void]$p.WaitForExit(300000)
    # The uninstaller of Inno hands over to a copy of itself: wait until it is really done.
    $t0 = Get-Date
    while ((Test-Path $AppKey) -and ((Get-Date) - $t0).TotalSeconds -lt 60) { Start-Sleep -Seconds 1 }
    CheckInnoLog 'uninstall' @{ code = $p.ExitCode; log = $ulog }
    Check 'uninstall the service is gone' ($null -eq (Get-Service $Svc -ErrorAction SilentlyContinue))
    Check 'uninstall no Charon WFP filter is left' ((WfpCount) -eq 0) (Wfp)
    # The copy of the uninstaller that does the last cleaning may still be running.
    $t0 = Get-Date
    do {
        $left = @(Get-ChildItem $ProgramDir -Recurse -Force -ErrorAction SilentlyContinue)
        if ($left.Count -eq 0) { break }
        Start-Sleep -Seconds 1
    } while (((Get-Date) - $t0).TotalSeconds -lt 30)
    Check 'uninstall the program folder is gone' ($left.Count -eq 0) ('left: ' + (($left | ForEach-Object { $_.FullName }) -join ', '))
    Check 'uninstall the Start menu shortcut is gone' (-not (Test-Path $Shortcut))
    Check 'uninstall the uninstall entry is gone' (-not (Test-Path $AppKey))
    Check 'uninstall the data folder is kept for a reinstall' (Test-Path (Join-Path $DataDir 'owner.sid'))
    }

    if ($Phases.Contains('4')) {
    Write-Host ''
    Write-Host '=== 4  install again after an uninstall' -ForegroundColor Cyan
    $r4 = RunSetup 'reinstall'
    CheckInnoLog 'reinstall' $r4
    VerifyInstall 'reinstall' $true
    }
}
catch {
    Write-Host "ABORTED: $_" -ForegroundColor Red
    $results.Add("ABORT  $_")
}
finally {
    Write-Host ''
    Write-Host '=== putting things back (always)' -ForegroundColor Cyan
    Get-Process -Name charon -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    if ($null -eq (Get-Service $Svc -ErrorAction SilentlyContinue)) {
        $inst = Join-Path $Restore 'install.ps1'
        if (Test-Path $inst) {
            Info "no service: putting the M2 test install back from $Restore"
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $inst -SourceDir $Restore 2>&1 | ForEach-Object { Info "$_" }
        }
    }
    if ($null -ne (Get-Service $Svc -ErrorAction SilentlyContinue) -and "$(State)" -ne 'Running') {
        & $Sc start $Svc | Out-Null
        [void](WaitFor 'Running' 20)
    }
    Info "the service is: $(State)"
    Info (Wfp)
    if ((WfpCount) -gt 0) {
        Write-Host '    Charon filters are still there. If the internet is blocked: "<program folder>\charon-release.exe" removes them.' -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host '=== SUMMARY'
    $results | ForEach-Object { Write-Host $_ }
    $fails = @($results | Where-Object { $_ -notmatch '^PASS' }).Count
    Write-Host ''
    Write-Host ("{0} checks, {1} not passed." -f $results.Count, $fails) -ForegroundColor $(if ($fails -eq 0) { 'Green' } else { 'Red' })
    Write-Host "DONE. You can start the v1 app again. Log: $LogDir\installer-test-$stamp.log" -ForegroundColor Cyan
    Stop-Transcript | Out-Null
}
