#Requires -RunAsAdministrator
<#
.SYNOPSIS
    The real connect test of M2, in one command, with everything written to a log.

.DESCRIPTION
    Run it from an elevated PowerShell, with the v1 app closed (Disconnect, then Quit).
    The tunnel of v1 is the one the owner reaches the internet through, so this test cuts
    that line for a few minutes: nothing needs to be typed while it runs, and the log has
    the answers afterwards.

    What it does, in order:
      1  baseline: the filters and the direct internet before anything
      2  connect through the service, and wait for Up
      3  while Up: the filters, the adapter, traffic through the tunnel, DNS
      4  the kill switch: xray is killed, traffic must be held, then the service must recover
      5  a custom DNS resolver: connect again with it (the DNS check of the connect then uses it)
      6  disconnect: every filter must be gone and the internet direct again
    It always ends with a disconnect and, if a filter is left, the release of the filters,
    also when something above failed or hung.

    Needs the Charon service installed (install.ps1) and Flutter on the PATH or in -Flutter.
    Writes no secret: the probe lists servers by code only.
#>
param(
    [string]$Stage = 'D:\charon-m2-test',
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$ProgramDir = "$env:ProgramFiles\Charon",
    [string]$CustomDns = '9.9.9.9',
    [switch]$SkipCrashTest,
    [switch]$SkipDnsTest
)

$ErrorActionPreference = 'Continue'
$App = (Resolve-Path $App).Path
$logDir = Join-Path $Stage 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("m2-connect-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Start-Transcript -Path $log | Out-Null

$results = New-Object System.Collections.Generic.List[string]
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    $line = '{0}  {1}{2}' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $name, $(if ($detail) { "  ($detail)" } else { '' })
    Write-Host $line -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $results.Add($line)
}
function Step([string]$t) { Write-Host ''; Write-Host "=== $t" -ForegroundColor Cyan }

# One call of the probe, in a job so that a hang cannot hold the test forever.
function Probe([string]$command, [int]$timeout = 150) {
    $job = Start-Job -ScriptBlock {
        param($app, $flutter, $c)
        $env:CHARON_PROBE = $c
        Set-Location $app
        & $flutter test test/m2_probe_test.dart 2>&1
    } -ArgumentList $App, $Flutter, $command
    if (Wait-Job $job -Timeout $timeout) {
        $out = Receive-Job $job
    } else {
        Stop-Job $job
        $out = @('Shell: PROBE TIMEOUT')
    }
    Remove-Job $job -Force
    $lines = @($out | ForEach-Object { "$_" } | Where-Object { $_ -match '^Shell:' } | ForEach-Object { $_ -replace '^Shell:\s?', '' })
    $lines | ForEach-Object { Write-Host "    $_" }
    return $lines
}

function Filters {
    $out = & "$Stage\charon-wfpcheck.exe" list 2>&1 | ForEach-Object { "$_" }
    $out | ForEach-Object { Write-Host "    $_" }
    return $out
}
# "Charon filters installed: N" is the first line of `charon-wfpcheck list`. -1 means
# the answer could not be read (the tool failed), which no check accepts.
function FilterCount($lines) {
    $m = $lines | Select-String -Pattern 'filters installed:\s*(\d+)' | Select-Object -First 1
    if ($m) { return [int]$m.Matches[0].Groups[1].Value }
    return -1
}

function Egress([int]$timeout = 15) {
    $t = & curl.exe -s -m $timeout --ssl-no-revoke https://www.cloudflare.com/cdn-cgi/trace 2>$null
    $ip = ($t | Where-Object { $_ -like 'ip=*' } | Select-Object -First 1)
    if ($ip) { return $ip.Substring(3) }
    return $null
}

function LastStatus($lines) { return ($lines | Where-Object { $_ -match 'phase=' } | Select-Object -Last 1) }
function Field($status, $name) {
    if ($status -match "$name=(\S+)") { return $Matches[1] }
    return ''
}

try {
    Step '0  before we start'
    $v1 = @(Get-Process CharonVPN -ErrorAction SilentlyContinue)
    $strayXray = @(Get-Process xray -ErrorAction SilentlyContinue | Where-Object { $_.Path -notlike "$ProgramDir\*" })
    if ($v1.Count -gt 0 -or $strayXray.Count -gt 0) {
        Write-Host 'The v1 app (or an xray that is not the service''s) is running.' -ForegroundColor Yellow
        Write-Host 'Disconnect it, quit it from its own Quit button (not End Task), and run this again.' -ForegroundColor Yellow
        Check 'v1 is closed' $false "$($v1.Count) CharonVPN, $($strayXray.Count) other xray"
        return
    }
    Check 'v1 is closed' $true
    $svc = Get-Service charon-service -ErrorAction SilentlyContinue
    Check 'the service is running' ($svc -and $svc.Status -eq 'Running')
    $hello = Probe 'hello'
    Check 'the service answers on its pipe' (@($hello | Where-Object { $_ -match 'service ' }).Count -gt 0)

    Step '1  baseline'
    $f0 = Filters
    Check 'no filter of Charon before the test' ((FilterCount $f0) -eq 0)
    $direct0 = Egress 8
    Write-Host "    direct internet before: $(if ($direct0) { $direct0 } else { 'no answer (normal behind the firewall)' })"

    Step '2  connect'
    $c = Probe 'connect' 120
    $st = LastStatus $c
    $up = $st -and (Field $st 'phase') -eq 'PHASE_UP'
    Check 'connected: the phase reached Up' $up $st
    if (-not $up) { throw 'did not reach Up, the rest cannot be tested' }
    $egress = Field $st 'egress'
    Start-Sleep -Seconds 4

    Step '3  while connected'
    $f1 = Filters
    $n1 = FilterCount $f1
    Check 'the filters of the kill switch are in' ($n1 -gt 0) "$n1 filters"
    $adapter = Get-NetAdapter -Name 'charon0' -ErrorAction SilentlyContinue
    Check 'the tunnel adapter charon0 is there and up' ($adapter -and $adapter.Status -eq 'Up') "$($adapter.Status)"
    $viaTunnel = Egress 20
    Write-Host "    internet while connected: $viaTunnel   (the server answered as: $egress)"
    Check 'traffic passes through the tunnel (the filters permit the adapter)' ($null -ne $viaTunnel)
    Check 'the address the internet sees is the server''s' ($viaTunnel -and $viaTunnel -eq $egress)
    $t0 = Get-Date
    $dns = Resolve-DnsName example.com -Type A -DnsOnly -ErrorAction SilentlyContinue
    $ms = [int]((Get-Date) - $t0).TotalMilliseconds
    Check 'DNS answers while connected' ($null -ne $dns) "$ms ms"
    $resolvers = (Get-DnsClientServerAddress -InterfaceAlias 'charon0' -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
    Write-Host "    DNS servers of charon0: $($resolvers -join ', ')"

    if (-not $SkipCrashTest) {
        Step '4  the kill switch: xray is killed'
        $x = @(Get-Process xray -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$ProgramDir\*" })
        Check 'the service''s xray is running' ($x.Count -gt 0)
        $x | Stop-Process -Force
        Start-Sleep -Seconds 2
        $held = Probe 'hello'
        $hs = LastStatus $held
        Write-Host "    two seconds after the crash: $hs"
        Check 'the service noticed: not Up with the gate Armed or Held' ($hs -and (Field $hs 'phase') -ne 'PHASE_UP')
        $leak = Egress 6
        Check 'while it is down, nothing leaves the PC' ($null -eq $leak) $(if ($leak) { "an answer came from $leak" } else { 'no answer' })
        Write-Host '    waiting for the service to bring the tunnel back...'
        $recovered = $false
        for ($i = 0; $i -lt 6 -and -not $recovered; $i++) {
            $w = Probe 'hello'
            $ws = LastStatus $w
            if ($ws -and (Field $ws 'phase') -eq 'PHASE_UP') { $recovered = $true }
            else { Start-Sleep -Seconds 5 }
        }
        Check 'the service reconnected on its own (auto reconnect)' $recovered
        if ($recovered) {
            $back = Egress 20
            Check 'traffic passes again after the recovery' ($null -ne $back)
        }
    }

    if (-not $SkipDnsTest) {
        Step "5  a custom DNS resolver ($CustomDns)"
        [void](Probe 'disconnect')
        [void](Probe "dns $CustomDns")
        $c2 = Probe 'connect' 120
        $st2 = LastStatus $c2
        $up2 = $st2 -and (Field $st2 'phase') -eq 'PHASE_UP'
        Check 'connected with the custom resolver (its DNS check passed through the tunnel)' $up2 $st2
        if ($up2) {
            Start-Sleep -Seconds 3
            $r = Resolve-DnsName example.com -Type A -DnsOnly -Server $CustomDns -ErrorAction SilentlyContinue
            Check "$CustomDns answers a lookup while connected" ($null -ne $r)
            $res2 = (Get-DnsClientServerAddress -InterfaceAlias 'charon0' -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            Write-Host "    DNS servers of charon0: $($res2 -join ', ')"
        }
    }

    Step '6  disconnect'
    $d = Probe 'disconnect'
    $ds = LastStatus $d
    Check 'idle and disarmed after a manual disconnect' ($ds -and (Field $ds 'phase') -eq 'PHASE_IDLE' -and (Field $ds 'gate') -eq 'GATE_DISARMED') $ds
    Start-Sleep -Seconds 2
    $f2 = Filters
    Check 'every filter is gone' ((FilterCount $f2) -eq 0)
    $adapterAfter = Get-NetAdapter -Name 'charon0' -ErrorAction SilentlyContinue
    Check 'the tunnel adapter is gone' ($null -eq $adapterAfter)
}
catch {
    Write-Host "STOPPED: $_" -ForegroundColor Red
    $results.Add("STOPPED  $_")
}
finally {
    Step 'cleaning up (always)'
    [void](Probe 'disconnect' 60)
    [void](Probe 'dns none' 60)
    $left = Filters
    if ((FilterCount $left) -gt 0) {
        Write-Host '    filters are still in: releasing them' -ForegroundColor Yellow
        & "$Stage\charon-wfpcheck.exe" release 2>&1 | ForEach-Object { Write-Host "    $_" }
        $after = Filters
        Check 'the filters were released by the emergency tool' ((FilterCount $after) -eq 0)
    }
    $direct = Egress 10
    Write-Host "    direct internet now: $(if ($direct) { $direct } else { 'no answer' })"

    Step 'SUMMARY'
    $results | ForEach-Object { Write-Host $_ }
    Write-Host ''
    Write-Host "Log: $log"
    Write-Host 'You can start the v1 app again.' -ForegroundColor Cyan
    Stop-Transcript | Out-Null
}
