#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Removes the Charon service, every persistent WFP protection filter, the
    program folder, and optionally the service data folder.
    Matches the Uninstall flow on the InstallerWindows board.
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$ProgramDir = "$env:ProgramFiles\Charon",

    [Parameter(Mandatory = $false)]
    [string]$DataDir = "$env:ProgramData\Charon",

    [Parameter(Mandatory = $false)]
    [switch]$RemoveData
)

$ErrorActionPreference = "Stop"
$ServiceName = "charon-service"

Write-Host "[1/4] Stopping and removing the Charon service..."
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    if ($existing.Status -ne "Stopped") {
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    & sc.exe delete $ServiceName | Out-Null
}

Write-Host "[2/4] Removing every Charon WFP protection filter..."
$releaseBin = Join-Path $ProgramDir "charon-release.exe"
if (Test-Path $releaseBin) {
    & $releaseBin
}

Write-Host "[3/4] Removing the program folder ($ProgramDir)..."
if (Test-Path $ProgramDir) {
    Remove-Item -Path $ProgramDir -Recurse -Force -ErrorAction SilentlyContinue
}

if ($RemoveData) {
    Write-Host "[4/4] Removing data folder ($DataDir)..."
    if (Test-Path $DataDir) {
        Remove-Item -Path $DataDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Charon is removed. Data folder removed."
} else {
    Write-Host "[4/4] Keeping data folder ($DataDir) for a reinstall."
    Write-Host "Charon is removed. Data folder kept."
}
