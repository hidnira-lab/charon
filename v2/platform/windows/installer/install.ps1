#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs the Charon program folder, wintun, LocalSystem service, and ACLs.
    Matches the steps on the InstallerWindows board.
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$SourceDir = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [string]$ProgramDir = "$env:ProgramFiles\Charon",

    [Parameter(Mandatory = $false)]
    [string]$DataDir = "$env:ProgramData\Charon",

    [Parameter(Mandatory = $false)]
    [string]$InstallingUserSID = ""
)

$ErrorActionPreference = "Stop"
$ServiceName = "charon-service"

if ([string]::IsNullOrWhiteSpace($InstallingUserSID)) {
    $InstallingUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
}

Write-Host "[1/4] Copying the Charon window and binaries to $ProgramDir..."
New-Item -ItemType Directory -Force -Path $ProgramDir | Out-Null
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

# Lock ACL on ProgramDir: SYSTEM and Administrators full control, Users read and execute only.
& icacls.exe $ProgramDir /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" "*S-1-5-32-545:(OI)(CI)RX" | Out-Null

# Lock ACL on DataDir: SYSTEM and Administrators only.
& icacls.exe $DataDir /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" | Out-Null

# Record the installing user's SID so the pipe server limits access to this user.
Set-Content -Path (Join-Path $DataDir "owner.sid") -Value $InstallingUserSID -Encoding ASCII -NoNewline

foreach ($file in @("charon.exe", "charon-service.exe", "charon-release.exe", "xray.exe", "wintun.dll")) {
    $src = Join-Path $SourceDir $file
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $ProgramDir $file) -Force
    }
}

Write-Host "[2/4] Installing the Charon service..."
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    if ($existing.Status -ne "Stopped") {
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    & sc.exe delete $ServiceName | Out-Null
    Start-Sleep -Seconds 1
}

$serviceBin = Join-Path $ProgramDir "charon-service.exe"
& sc.exe create $ServiceName binPath= "`"$serviceBin`"" start= auto obj= LocalSystem depend= Tcpip/Nsi DisplayName= "Charon Service" | Out-Null
& sc.exe description $ServiceName "Charon VPN tunnel supervisor and persistent WFP kill switch service." | Out-Null
& sc.exe failure $ServiceName reset= 86400 actions= restart/5000/restart/5000/restart/5000 | Out-Null
& sc.exe failureflag $ServiceName 1 | Out-Null

# Allow the installing user to query and start the service without UAC, while stopping requires admin.
$sddl = "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCRPRC;;;$InstallingUserSID)"
& sc.exe sdset $ServiceName $sddl | Out-Null

Write-Host "[3/4] Adding wintun and registering protection filters..."
Start-Service -Name $ServiceName

Write-Host "[4/4] Charon is installed. The service is running."
