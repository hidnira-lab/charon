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
    [string]$InstallingUserSID = "",

    # The window runs this from the program folder to put the service back ("Repair").
    # The files are already where they belong, and the owner of the pipe is the user
    # recorded at the first install, not whoever types the admin password now.
    [switch]$Repair
)

$ErrorActionPreference = "Stop"
$ServiceName = "charon-service"

# The window runs a repair with a hidden window and only sees the exit code, so the
# record of what happened goes to a file that the same user can read afterwards.
$RepairLog = Join-Path $env:TEMP "charon-repair.log"
if ($Repair) {
    Start-Transcript -Path $RepairLog -Force | Out-Null
}

# sc.exe does not throw, and the old script did not look at its exit code: a failed
# "create" went by unnoticed and the service was missing at "Start-Service".
function Invoke-Sc {
    $out = & sc.exe @args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "sc.exe $($args[0]) failed with $LASTEXITCODE : $out"
    }
}

if ([string]::IsNullOrWhiteSpace($InstallingUserSID)) {
    $ownerFile = Join-Path $DataDir "owner.sid"
    if ($Repair -and (Test-Path $ownerFile)) {
        $InstallingUserSID = (Get-Content -Path $ownerFile -Raw).Trim()
    } else {
        $InstallingUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    }
}

# A running service keeps charon-service.exe locked, so stop it before the copy
# (an upgrade over an existing install would otherwise fail with "in use").
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -ne $existing -and $existing.Status -ne "Stopped") {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    $existing.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(15))
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

# install.ps1 and uninstall.ps1 go along, so that the window can find the script of
# "Repair" in the program folder, which only administrators can write to.
# When the files are already in the program folder (a repair), copying a file onto
# itself is an error, so nothing is copied.
$sameFolder = (Resolve-Path -Path $SourceDir).Path.TrimEnd('\') -ieq (Resolve-Path -Path $ProgramDir).Path.TrimEnd('\')
if (-not $sameFolder) {
    foreach ($file in @("charon.exe", "charon-service.exe", "charon-release.exe", "xray.exe", "wintun.dll", "install.ps1", "uninstall.ps1")) {
        $src = Join-Path $SourceDir $file
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $ProgramDir $file) -Force
        }
    }
}

Write-Host "[2/4] Installing the Charon service..."
$serviceBin = Join-Path $ProgramDir "charon-service.exe"
if ($null -ne $existing) {
    # The service is there (an upgrade or a repair): set it right where it stands.
    # Deleting it and creating it again fails with "marked for deletion" as long as any
    # program still holds a handle to it, and it loses nothing that "config" keeps.
    Invoke-Sc config $ServiceName binPath= "`"$serviceBin`"" start= auto obj= LocalSystem depend= Tcpip/Nsi DisplayName= "Charon Service"
} else {
    Invoke-Sc create $ServiceName binPath= "`"$serviceBin`"" start= auto obj= LocalSystem depend= Tcpip/Nsi DisplayName= "Charon Service"
}
Invoke-Sc description $ServiceName "Charon VPN tunnel supervisor and persistent WFP kill switch service."
Invoke-Sc failure $ServiceName reset= 86400 actions= restart/5000/restart/5000/restart/5000
Invoke-Sc failureflag $ServiceName 1

# Allow the installing user to query and start the service without UAC, while stopping requires admin.
$sddl = "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCRPRC;;;$InstallingUserSID)"
Invoke-Sc sdset $ServiceName $sddl

Write-Host "[3/4] Adding wintun and registering protection filters..."
Start-Service -Name $ServiceName

Write-Host "[4/4] Charon is installed. The service is running."
if ($Repair) {
    Stop-Transcript | Out-Null
}
