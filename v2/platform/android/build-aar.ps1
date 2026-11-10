param(
    [string]$Target = "android/arm64",
    [string]$AndroidApi = "24",
    [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"
$AndroidRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$V2Root = Split-Path -Parent (Split-Path -Parent $AndroidRoot)

if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path $V2Root "app\android\app\libs\charoncore.aar"
}

$OutDir = Split-Path -Parent $OutFile
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

if (-not (Get-Command gomobile -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing gomobile & gobind..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    go install golang.org/x/mobile/cmd/gobind@latest
    $env:PATH += ";$env:USERPROFILE\go\bin"
}

Push-Location $AndroidRoot
try {
    Write-Host "==> Building charoncore.aar for $Target (API $AndroidApi)..."
    & gomobile bind -v -target=$Target -androidapi $AndroidApi -javapkg=app.charon.bridge -o $OutFile ./bridge
    if ($LASTEXITCODE -ne 0) {
        throw "gomobile bind failed with exit code $LASTEXITCODE"
    }
    $item = Get-Item $OutFile
    $sizeMB = [math]::Round($item.Length / 1MB, 2)
    Write-Host "==> Built $($item.FullName) ($sizeMB MB)"
} finally {
    Pop-Location
}
