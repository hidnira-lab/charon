param(
    [string]$Version = "0.1.0",
    [uint64]$Sequence = 1,
    [string]$MinVersion = "0.1.0",
    [string]$CoreVersion = "26.3.27",
    [string]$CoreFile = "",
    [string]$CoreSha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    [string]$OutDir = "dist",
    [string]$SignKeyPath = "",
    [switch]$SkipFlutter
)

$ErrorActionPreference = "Stop"
$v2Root = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $v2Root $OutDir
if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$stageWin = Join-Path $distDir "charon-windows-amd64"
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
} finally {
    Pop-Location
}

Write-Host "==> Building Windows service and emergency release tool..."
Push-Location (Join-Path $v2Root "platform\windows")
try {
    go build -trimpath -ldflags "-s -w" -o (Join-Path $stageWin "charon-service.exe") ./cmd/charon-service
    go build -trimpath -ldflags "-s -w" -o (Join-Path $stageWin "charon-release.exe") ./cmd/charon-release
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

    $env:GOOS = "linux"
    $env:GOARCH = "amd64"
    go build -trimpath -ldflags "-s -w" -o $syncLinuxOut ./cmd/charonsync
} finally {
    Remove-Item Env:\GOOS -ErrorAction SilentlyContinue
    Remove-Item Env:\GOARCH -ErrorAction SilentlyContinue
    Pop-Location
}

if (-not $SkipFlutter) {
    Write-Host "==> Building Flutter Windows release..."
    Push-Location (Join-Path $v2Root "app")
    try {
        flutter build windows --release
        $flutterReleaseDir = Join-Path $v2Root "app\build\windows\x64\runner\Release"
        Copy-Item -Path (Join-Path $flutterReleaseDir "*") -Destination $stageWin -Recurse -Force
    } finally {
        Pop-Location
    }
}

$winZipPath = Join-Path $distDir "charon-windows-amd64.zip"
Compress-Archive -Path (Join-Path $stageWin "*") -DestinationPath $winZipPath -Force
Remove-Item -Recurse -Force $stageWin

$manifestPath = Join-Path $distDir "manifest.json"
$manifestArgs = @(
    "manifest",
    "-version", $Version,
    "-min-version", $MinVersion,
    "-sequence", "$Sequence",
    "-commit", $commit,
    "-core-version", $CoreVersion,
    "-out", $manifestPath,
    "-artifact", "windows-amd64:app:$winZipPath",
    "-artifact", "windows-amd64:sync-server:$syncWinOut",
    "-artifact", "linux-amd64:sync-server:$syncLinuxOut"
)

if ($CoreFile -ne "" -and (Test-Path $CoreFile)) {
    $coreDest = Join-Path $distDir "xray-windows-amd64.exe"
    Copy-Item -Path $CoreFile -Destination $coreDest -Force
    $manifestArgs += @("-core-file", $coreDest, "-artifact", "windows-amd64:core:$coreDest")
} else {
    $manifestArgs += @("-core-sha256", $CoreSha256)
}

Write-Host "==> Generating release manifest.json..."
& $signExe @manifestArgs
if ($LASTEXITCODE -ne 0) {
    throw "charon-sign manifest failed"
}

if ($SignKeyPath -ne "" -and (Test-Path $SignKeyPath)) {
    Write-Host "==> Signing manifest.json with offline key..."
    & $signExe sign -key $SignKeyPath -in $manifestPath
    if ($LASTEXITCODE -ne 0) {
        throw "charon-sign sign failed"
    }
}

Write-Host "==> Release artifacts packaged in $distDir"
