<#
.SYNOPSIS
    The real UAC test of the window: Yes gives the program's exit code, No gives 1223.

.DESCRIPTION
    Run it from a NORMAL PowerShell (not "Run as administrator"). In an elevated one
    Windows shows no prompt and the test would prove nothing, so it refuses to run there.

    It uses the same function the window uses to start the installer (runElevated in
    app/lib/core/elevated.dart), with a harmless program: charon-release.exe, which only
    removes the filters of Charon (none are installed when the service is idle). Twice:
      1  a UAC prompt appears: click YES   -> the exit code of the program, 0
      2  a UAC prompt appears: click NO    -> 1223 (the operation was canceled by the user)
    Needs the Charon service installed (install.ps1), so that the probe can say hello,
    and Flutter on the PATH or in -Flutter.
#>
param(
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$Target = "$env:ProgramFiles\Charon\charon-release.exe"
)
$ErrorActionPreference = 'Continue'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host 'This PowerShell is elevated: Windows would show no prompt. Open a normal one and run it again.' -ForegroundColor Yellow
    return
}
if (-not (Test-Path $Target)) {
    Write-Host "The program to run is not there: $Target" -ForegroundColor Yellow
    return
}
$App = (Resolve-Path $App).Path

function Elevate([string]$what) {
    Write-Host ''
    Write-Host $what -ForegroundColor Cyan
    $job = Start-Job -ScriptBlock {
        param($app, $flutter, $target)
        $env:CHARON_PROBE = "elevate $target"
        Set-Location $app
        & $flutter test test/m2_probe_test.dart 2>&1
    } -ArgumentList $App, $Flutter, $Target
    if (Wait-Job $job -Timeout 150) { $out = Receive-Job $job } else { Stop-Job $job; $out = @('Shell: TIMEOUT') }
    Remove-Job $job -Force
    $line = $out | ForEach-Object { "$_" } | Where-Object { $_ -match 'elevated exit code|TIMEOUT|CANNOT' } | Select-Object -First 1
    Write-Host "    $line"
    if ($line -match 'exit code: (-?\d+)') { return [int]$Matches[1] }
    return $null
}

$results = @()
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    $l = '{0}  {1}{2}' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $name, $(if ($detail) { "  ($detail)" } else { '' })
    Write-Host $l -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $script:results += $l
}

$yes = Elevate '1  A UAC prompt will appear. Click YES.'
Check 'Yes: the program ran as administrator and gave its exit code' ($yes -eq 0) "exit code $yes"

$no = Elevate '2  A UAC prompt will appear. Click NO (or close it).'
Check 'No: the window learns the prompt was declined (1223)' ($no -eq 1223) "exit code $no"

Write-Host ''
Write-Host '=== SUMMARY'
$results | ForEach-Object { Write-Host $_ }
