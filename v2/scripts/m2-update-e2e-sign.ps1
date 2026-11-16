<#
.SYNOPSIS
    Signs the manifests of the update end to end test with the offline release key, and
    checks each signature against the public keys embedded in the service.

.DESCRIPTION
    Run it yourself, from a normal PowerShell, after m2-update-e2e-prepare.ps1:
      m2-update-e2e-sign.ps1 -KeyPath <the private key file>
    The key is only handed to charon-sign, which reads it to sign. Nothing here (and nobody
    else who runs the test) ever reads, copies or prints it. The check that follows uses the
    keys embedded in the service, so a wrong key shows up here and not in the middle of the test.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$KeyPath,
    # The default is set below, not here: in Windows PowerShell 5.1 a script with a
    # [Parameter()] attribute gets an EMPTY $PSScriptRoot in a default value when it runs
    # with -File.
    [string]$Dir = ''
)

# Not 'Stop': in Windows PowerShell 5.1 the stderr of a native program that fails (a wrong
# key makes charon-sign verify write to it) would end the script at once with a raw error,
# instead of the FAIL line below. The exit codes are checked by hand.
$ErrorActionPreference = 'Continue'
if (-not $Dir) { $Dir = Join-Path $PSScriptRoot '..\dist-e2e' }
$Dir = (Resolve-Path $Dir).Path
$sign = Join-Path $Dir 'charon-sign.exe'
if (-not (Test-Path $KeyPath)) { throw "No key file at $KeyPath" }
if (-not (Test-Path $sign)) { throw "No $sign. Run m2-update-e2e-prepare.ps1 first." }

$bad = 0
foreach ($m in 'm10', 'm11', 'm12', 'm13', 'm14') {
    $file = Join-Path $Dir "manifests\$m.json"
    & $sign sign -key $KeyPath -in $file
    if ($LASTEXITCODE -ne 0) { Write-Host "FAIL  sign $m" -ForegroundColor Red; $bad++; continue }
    $out = & $sign verify -in $file -sig "$file.sig" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host "OK    $m  $out" -ForegroundColor Green }
    else { Write-Host "FAIL  $m is signed but the embedded keys do not accept it: $out" -ForegroundColor Red; $bad++ }
}
if ($bad -eq 0) { Write-Host 'All signed. Next: m2-update-e2e.ps1 from an administrator PowerShell.' -ForegroundColor Cyan }
else { Write-Host "$bad problem(s). Do not run the test before this is fixed." -ForegroundColor Red }
