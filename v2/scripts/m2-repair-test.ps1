<#
.SYNOPSIS
    The real test of "Repair with the installer": a stopped service is put back, and a No
    to the UAC prompt leaves things as they were, with no error.

.DESCRIPTION
    Run it from a NORMAL PowerShell (not "Run as administrator"): the whole point is the
    UAC prompt. Four prompts appear, and each is announced:
      A  stop the service (YES), then Repair (YES)  -> the service runs again
      B  stop the service (YES), then Repair (NO)   -> no error, and the service is still stopped
    Stopping a service needs admin (the service's security descriptor), so the stop is
    also done through the prompt. At the end the service is started again in any case,
    which the installing user may do without admin.

    Needs the install script in the program folder: run the install.ps1 of the new build
    once as an administrator (it copies itself there). The v1 app can stay open: the
    test touches only the Charon v2 service and no tunnel.
#>
param(
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$ProgramDir = "$env:ProgramFiles\Charon",
    # Only the part with the answer YES (two prompts, instead of four).
    [switch]$OnlyYes
)
$ErrorActionPreference = 'Continue'
$Svc = 'charon-service'
$Sc = Join-Path $env:SystemRoot 'System32\sc.exe'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host 'This PowerShell is elevated: Windows would show no prompt. Open a normal one and run it again.' -ForegroundColor Yellow
    return
}
if (-not (Test-Path (Join-Path $ProgramDir 'install.ps1'))) {
    Write-Host "There is no install.ps1 in $ProgramDir." -ForegroundColor Yellow
    Write-Host 'Run the install.ps1 of the new build once from an administrator PowerShell (it copies itself there), then run this again.' -ForegroundColor Yellow
    return
}
$App = (Resolve-Path $App).Path

$results = New-Object System.Collections.Generic.List[string]
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    $l = '{0}  {1}{2}' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $name, $(if ($detail) { "  ($detail)" } else { '' })
    Write-Host $l -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $results.Add($l)
}

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
    $lines | ForEach-Object { Write-Host "    $_" }
    return $lines
}

function State { return (Get-Service $Svc -ErrorAction SilentlyContinue).Status }
function WaitFor([string]$want, [int]$seconds = 25) {
    $t0 = Get-Date
    while (((Get-Date) - $t0).TotalSeconds -lt $seconds) {
        if ("$(State)" -eq $want) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}
function StopThroughPrompt {
    Write-Host '    A prompt will appear to STOP the service. Click YES.' -ForegroundColor Cyan
    [void](Probe "elevate $Sc -- stop $Svc")
    return (WaitFor 'Stopped')
}
function After($lines) { return ($lines | Where-Object { $_ -match '^after:' } | Select-Object -Last 1) }

try {
    Write-Host '=== 0  before'
    Check 'the service is installed and running' ("$(State)" -eq 'Running') "$(State)"

    Write-Host ''
    Write-Host '=== A  Repair, and the answer is YES' -ForegroundColor Cyan
    Check 'the service was stopped (to look broken)' (StopThroughPrompt) "$(State)"
    Write-Host '    A prompt will appear for the REPAIR. Click YES. It takes some seconds.' -ForegroundColor Cyan
    $r = Probe 'repair'
    $a = After $r
    Check 'the window reports the service back' ($a -match 'running' -and $a -match 'startFailed=false' -and $a -match 'recovered=back') $a
    Check 'the service is running again' ("$(State)" -eq 'Running') "$(State)"

    if (-not $OnlyYes) {
        Write-Host ''
        Write-Host '=== B  Repair, and the answer is NO' -ForegroundColor Cyan
        Check 'the service was stopped again' (StopThroughPrompt) "$(State)"
        Write-Host '    A prompt will appear for the REPAIR. Click NO (or close it).' -ForegroundColor Cyan
        $r2 = Probe 'repair'
        $b = After $r2
        Check 'a No shows no error and no confirmation' ($b -match 'startFailed=false' -and $b -match 'recovered=null' -and $b -match 'installing=null') $b
        Check 'the service is still stopped (nothing was run)' ("$(State)" -eq 'Stopped') "$(State)"
    }
}
finally {
    Write-Host ''
    Write-Host '=== putting the service back (always)'
    if ("$(State)" -ne 'Running') {
        & $Sc start $Svc | Out-Null
        [void](WaitFor 'Running' 20)
    }
    Write-Host "    the service is: $(State)"
    Write-Host ''
    Write-Host '=== SUMMARY'
    $results | ForEach-Object { Write-Host $_ }
}
