#Requires -RunAsAdministrator
<#
.SYNOPSIS
    A short test: does a name that has an IPv6 address fail while connected?

.DESCRIPTION
    Run it from an elevated PowerShell with the v1 app closed (same rules as m2-connect-test.ps1).
    It connects, asks the system for the A and AAAA records of one name, then fetches the
    name three ways: as the system chooses, forced to IPv4 and forced to IPv6. It always
    ends with a disconnect. The line cut for the owner lasts about one minute.
#>
param(
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$Name = 'www.cloudflare.com',
    # on (the default) or off: the safety switch for the run. It is always put back to on.
    [ValidateSet('on', 'off')][string]$KillSwitch = 'on'
)
$ErrorActionPreference = 'Continue'
$App = (Resolve-Path $App).Path

function Probe([string]$command, [int]$timeout = 120) {
    $job = Start-Job -ScriptBlock {
        param($app, $flutter, $c)
        $env:CHARON_PROBE = $c
        Set-Location $app
        & $flutter test test/m2_probe_test.dart 2>&1
    } -ArgumentList $App, $Flutter, $command
    if (Wait-Job $job -Timeout $timeout) { $out = Receive-Job $job } else { Stop-Job $job; $out = @('Shell: PROBE TIMEOUT') }
    Remove-Job $job -Force
    $lines = @($out | ForEach-Object { "$_" } | Where-Object { $_ -match '^Shell:' } | ForEach-Object { $_ -replace '^Shell:\s?', '' })
    $lines | ForEach-Object { Write-Host "    $_" }
    return $lines
}

function Fetch([string]$label, [string[]]$extra) {
    $out = & curl.exe -sS -m 12 --ssl-no-revoke @extra -o NUL -w 'code=%{http_code} remote=%{remote_ip} connect=%{time_connect}s total=%{time_total}s' "https://$Name/cdn-cgi/trace" 2>&1
    Write-Host ("    {0,-22} {1}" -f $label, (($out | ForEach-Object { "$_" }) -join ' | '))
}

try {
    if (@(Get-Process CharonVPN -ErrorAction SilentlyContinue).Count -gt 0) {
        Write-Host 'The v1 app is running. Quit it first.' -ForegroundColor Yellow
        return
    }
    Write-Host "=== kill switch $KillSwitch"
    [void](Probe "killswitch $KillSwitch")
    Write-Host '=== connect'
    $c = Probe 'connect'
    $up = @($c | Where-Object { $_ -match 'phase=PHASE_UP' }).Count -gt 0
    if (-not $up) { Write-Host 'did not reach Up' -ForegroundColor Red; return }
    Start-Sleep -Seconds 5

    Write-Host "=== records of $Name"
    foreach ($t in 'A', 'AAAA') {
        $r = Resolve-DnsName $Name -Type $t -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq $t }
        Write-Host ("    {0,-5} {1}" -f $t, $(if ($r) { ($r.IPAddress -join ', ') } else { '(none)' }))
    }

    Write-Host '=== three fetches'
    Fetch 'system choice' @()
    Fetch 'forced IPv4 (-4)' @('-4')
    Fetch 'forced IPv6 (-6)' @('-6')
    Fetch 'system choice again' @()
    # A leak probe: an IPv6 address, no name, so DNS cannot be the reason. It must NOT
    # answer. If the PC has no IPv6 at all it fails for that reason and proves nothing.
    $hasV6 = @(Get-NetRoute -AddressFamily IPv6 -DestinationPrefix '::/0' -ErrorAction SilentlyContinue).Count -gt 0
    Write-Host "    this PC has an IPv6 default route: $hasV6"
    $probe = & curl.exe -sS -6 -m 8 --ssl-no-revoke -o NUL -w '%{http_code}' 'https://[2606:4700:4700::1111]/cdn-cgi/trace' 2>&1 | ForEach-Object { "$_" }
    if (($probe -join '') -match '^200') {
        Write-Host '    IPv6 LEAK: an IPv6 address answered while connected' -ForegroundColor Red
    } elseif ($hasV6) {
        Write-Host "    no leak: the IPv6 literal did not answer ($($probe -join ' | '))" -ForegroundColor Green
    } else {
        Write-Host "    the IPv6 literal did not answer, but this PC has no IPv6, so that proves nothing ($($probe -join ' | '))" -ForegroundColor Yellow
    }
    Write-Host '    verbose, system choice:'
    & curl.exe -sS -v -m 12 --ssl-no-revoke -o NUL "https://$Name/cdn-cgi/trace" 2>&1 |
        ForEach-Object { "$_" } | Where-Object { $_ -match 'Trying|Connected to|reset|error|SSL|refused|unreachable|denied' } |
        ForEach-Object { Write-Host "      $_" }
}
finally {
    Write-Host '=== disconnect (always)'
    [void](Probe 'disconnect' 60)
    [void](Probe 'killswitch on' 60)
    $left = & "D:\charon-m2-test\charon-wfpcheck.exe" list 2>&1 | Select-Object -First 1
    Write-Host "    $left"
    Write-Host 'You can start the v1 app again.' -ForegroundColor Cyan
}
