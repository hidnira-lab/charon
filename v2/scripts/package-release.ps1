# Builds everything a Windows release needs and writes it to v2/dist:
#   Charon-Setup-<version>.exe   the Inno installer, the "app" artifact of the manifest
#   xray-windows-amd64.exe       the pinned Xray core, the "core" artifact of the manifest
#   charonsync-*                 the sync server
#   manifest.json                unsigned, the owner signs it offline with charon-sign
param(
    [string]$Version = "0.1.0",
    [uint64]$Sequence = 1,
    [string]$MinVersion = "0.1.0",
    [string]$OutDir = "dist",
    [string]$SignKeyPath = "",
    [switch]$SkipFlutter
)

$ErrorActionPreference = "Stop"

# Pinned third party binaries. Update them deliberately (CLAUDE.md section 5), with the
# hash taken from the official digest (Xray publishes a .dgst next to the zip).
$XrayVersion = "26.10.31"
$XrayUrl = "https://github.com/XTLS/Xray-core/releases/download/v$XrayVersion/Xray-windows-64.zip"
$XraySha256 = "2e04a9995a6f2ad1b28c0bb25c708ecb2695e43a1c9c7889c4b6ac2b48cf7a6a"
$WintunVersion = "0.14.1"
$WintunUrl = "https://www.wintun.net/builds/wintun-$WintunVersion.zip"
$WintunSha256 = "07c256185d6ee3652e09fa55c0b673e2624b565e02c4b9091c79ca7d2f24ef51"

# Native programs do not throw under $ErrorActionPreference, so a failed build would
# go by and leave a release without its parts.
function Assert-Ok([string]$what) {
    if ($LASTEXITCODE -ne 0) { throw "$what failed with exit code $LASTEXITCODE" }
}

function Get-Pinned([string]$url, [string]$sha256, [string]$to) {
    Invoke-WebRequest -Uri $url -OutFile $to -UseBasicParsing
    $got = (Get-FileHash -Algorithm SHA256 -Path $to).Hash.ToLowerInvariant()
    if ($got -ne $sha256) { throw "$url has sha256 $got, expected $sha256" }
}

$v2Root = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $v2Root $OutDir
if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$stageWin = Join-Path $distDir "stage"
New-Item -ItemType Directory -Force -Path $stageWin | Out-Null

$commit = (git -C $v2Root rev-parse HEAD 2>$null)
if (-not $commit) {
    $commit = "unknown"
} else {
    $commit = $commit.Trim()
}

Write-Host "==> Building charon-sign CLI..."
$signExe = Join-Path $distDir "charon-sign.exe"
Push-Location (Join-Path $v2Root "core")
try {
    go build -trimpath -ldflags "-s -w" -o $signExe ./cmd/charon-sign
    Assert-Ok "go build charon-sign"
} finally {
    Pop-Location
}

Write-Host "==> Building Windows service and emergency release tool..."
Push-Location (Join-Path $v2Root "platform\windows")
try {
    go build -trimpath -ldflags "-s -w" -o (Join-Path $stageWin "charon-service.exe") ./cmd/charon-service
    Assert-Ok "go build charon-service"
    go build -trimpath -ldflags "-s -w" -o (Join-Path $stageWin "charon-release.exe") ./cmd/charon-release
    Assert-Ok "go build charon-release"
} finally {
    Pop-Location
}

Write-Host "==> Building charonsync server (windows-amd64 & linux-amd64)..."
$syncWinOut = Join-Path $distDir "charonsync-windows-amd64.exe"
$syncLinuxOut = Join-Path $distDir "charonsync-linux-amd64"
Push-Location (Join-Path $v2Root "server\charonsync")
try {
    $env:GOOS = "windows"
    $env:GOARCH = "amd64"
    go build -trimpath -ldflags "-s -w" -o $syncWinOut ./cmd/charonsync
    Assert-Ok "go build charonsync (windows)"

    $env:GOOS = "linux"
    $env:GOARCH = "amd64"
    go build -trimpath -ldflags "-s -w" -o $syncLinuxOut ./cmd/charonsync
    Assert-Ok "go build charonsync (linux)"
} finally {
    Remove-Item Env:\GOOS -ErrorAction SilentlyContinue
    Remove-Item Env:\GOARCH -ErrorAction SilentlyContinue
    Pop-Location
}

Write-Host "==> Fetching pinned Xray $XrayVersion and wintun $WintunVersion..."
$dl = Join-Path $distDir "download"
New-Item -ItemType Directory -Force -Path $dl | Out-Null
$ProgressPreference = "SilentlyContinue"
Get-Pinned $XrayUrl $XraySha256 (Join-Path $dl "xray.zip")
Get-Pinned $WintunUrl $WintunSha256 (Join-Path $dl "wintun.zip")
Expand-Archive -Path (Join-Path $dl "xray.zip") -DestinationPath (Join-Path $dl "xray") -Force
Expand-Archive -Path (Join-Path $dl "wintun.zip") -DestinationPath (Join-Path $dl "wintun") -Force
$xrayExe = Join-Path $distDir "xray-windows-amd64.exe"
Copy-Item (Join-Path $dl "xray\xray.exe") $xrayExe
Copy-Item $xrayExe (Join-Path $stageWin "xray.exe")
Copy-Item (Join-Path $dl "wintun\wintun\bin\amd64\wintun.dll") (Join-Path $stageWin "wintun.dll")
Remove-Item -Recurse -Force $dl

if (-not $SkipFlutter) {
    Write-Host "==> Building Flutter Windows release..."
    Push-Location (Join-Path $v2Root "app")
    try {
        flutter build windows --release
        Assert-Ok "flutter build windows"
        $flutterReleaseDir = Join-Path $v2Root "app\build\windows\x64\runner\Release"
        Copy-Item -Path (Join-Path $flutterReleaseDir "*") -Destination $stageWin -Recurse -Force
    } finally {
        Pop-Location
    }
} else {
    Write-Warning "SkipFlutter: the installer has no charon.exe window, only for testing the packaging."
}

Write-Host "==> Building the installer with Inno Setup..."
$iscc = @(
    (Get-Command iscc -ErrorAction SilentlyContinue).Source,
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $iscc) {
    throw "Inno Setup 6 not found (winget install JRSoftware.InnoSetup)"
}
$iss = Join-Path $v2Root "platform\windows\installer\charon.iss"
& $iscc "/DMyAppVersion=$Version" "/DSourceDir=$stageWin" "/O$distDir" "/Q" $iss
Assert-Ok "iscc"
$installerPath = Join-Path $distDir "Charon-Setup-$Version.exe"
if (-not (Test-Path $installerPath)) {
    throw "iscc did not write $installerPath"
}
Remove-Item -Recurse -Force $stageWin

$manifestPath = Join-Path $distDir "manifest.json"
$manifestArgs = @(
    "manifest",
    "-version", $Version,
    "-min-version", $MinVersion,
    "-sequence", "$Sequence",
    "-commit", $commit,
    "-core-version", $XrayVersion,
    "-core-file", $xrayExe,
    "-out", $manifestPath,
    "-artifact", "windows-amd64:app:$installerPath",
    "-artifact", "windows-amd64:core:$xrayExe",
    "-artifact", "windows-amd64:sync-server:$syncWinOut",
    "-artifact", "linux-amd64:sync-server:$syncLinuxOut"
)

Write-Host "==> Generating release manifest.json..."
& $signExe @manifestArgs
Assert-Ok "charon-sign manifest"

if ($SignKeyPath -ne "" -and (Test-Path $SignKeyPath)) {
    Write-Host "==> Signing manifest.json with offline key..."
    & $signExe sign -key $SignKeyPath -in $manifestPath
    Assert-Ok "charon-sign sign"
}

Write-Host "==> Release artifacts packaged in $distDir"
