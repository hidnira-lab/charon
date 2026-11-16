<#
.SYNOPSIS
    Builds what the update end to end test needs, in v2/dist-e2e. Nothing is signed here.

.DESCRIPTION
    Run it from a normal PowerShell (it takes a few minutes: it builds the 0.1.0 release
    and a 0.1.1 test installer). Then sign the manifests with m2-update-e2e-sign.ps1, which
    takes the path of the offline release key, and then run m2-update-e2e.ps1 as an
    administrator.

    What it makes:
      start/xray.exe        Xray 26.10.21, the core the test starts from (a real older core
                            that takes the TUN config, so the service can connect with it)
      serve/                what the test web server serves: the installers, the real new
                            core (the pinned 26.10.31) and two fake cores
      manifests/m10..m14    the manifests, one per step of the test (unsigned)

    The fake cores are tiny programs: one takes `run -test` and then never opens a SOCKS
    port (the handshake check must fail and the old core must come back), the other
    rejects `run -test` (the config check must refuse it).
#>
param(
    [string]$Out = 'dist-e2e',
    # Xray 26.10.21, hash from the official digest of the release.
    [string]$StartXrayUrl = 'https://github.com/XTLS/Xray-core/releases/download/v26.10.21/Xray-windows-64.zip',
    [string]$StartXraySha256 = 'fc58c39ee2f2717b4c54d28d374362389e5319b20ae44aea76ea45a5243ec827'
)

$ErrorActionPreference = 'Stop'
function Assert-Ok([string]$what) { if ($LASTEXITCODE -ne 0) { throw "$what failed with exit code $LASTEXITCODE" } }

$v2 = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $v2 'dist'
$e2e = Join-Path $v2 $Out
$pkg = Join-Path $PSScriptRoot 'package-release.ps1'

Write-Host '==> 1/5  the 0.1.0 release (dist/): the build the test goes back to at the end'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pkg -Version '0.1.0' -Sequence 1
Assert-Ok 'package-release 0.1.0'

Write-Host '==> 2/5  a 0.1.1 test installer (not for release: no window in it)'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pkg -Version '0.1.1' -Sequence 13 -OutDir $Out -SkipFlutter
Assert-Ok 'package-release 0.1.1'

$serve = Join-Path $e2e 'serve'
$mf = Join-Path $e2e 'manifests'
$start = Join-Path $e2e 'start'
New-Item -ItemType Directory -Force -Path $serve, $mf, $start | Out-Null

Write-Host '==> 3/5  the start core, Xray 26.10.21'
$zip = Join-Path $e2e 'start-xray.zip'
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $StartXrayUrl -OutFile $zip -UseBasicParsing
$got = (Get-FileHash -Algorithm SHA256 -Path $zip).Hash.ToLowerInvariant()
if ($got -ne $StartXraySha256) { throw "$StartXrayUrl has sha256 $got, expected $StartXraySha256" }
Expand-Archive -Path $zip -DestinationPath (Join-Path $e2e 'start-xray') -Force
Copy-Item (Join-Path $e2e 'start-xray\xray.exe') (Join-Path $start 'xray.exe') -Force
Remove-Item -Recurse -Force $zip, (Join-Path $e2e 'start-xray')

Write-Host '==> 4/5  the fake cores'
$src = Join-Path $e2e 'fake'
New-Item -ItemType Directory -Force -Path $src | Out-Null
@'
package main

import (
	"fmt"
	"os"
	"time"
)

// A stand in for xray.exe, made only for the update test. The build sets what it does:
//   -X main.version=...   what `version` says
//   -X main.testFails=yes `run -test` rejects the config
// `run` (without -test) starts and then never opens a SOCKS port.
var (
	version   = "26.10.40"
	testFails = "no"
)

func main() {
	args := os.Args[1:]
	if len(args) > 0 && args[0] == "version" {
		fmt.Printf("Xray %s (fake core for the update test)\n", version)
		return
	}
	for _, a := range args {
		if a == "-test" {
			if testFails == "yes" {
				fmt.Fprintln(os.Stderr, "Failed to start: the fake core rejects every config")
				os.Exit(23)
			}
			fmt.Println("Configuration OK.")
			return
		}
	}
	time.Sleep(10 * time.Minute)
}
'@ | Set-Content -Path (Join-Path $src 'fake.go') -Encoding ASCII
$nosocks = Join-Path $serve 'xray-fake-nosocks-windows-amd64.exe'
$badcfg = Join-Path $serve 'xray-fake-badconfig-windows-amd64.exe'
Push-Location $src   # outside the module: it builds as a single file
try {
    go build -ldflags '-X main.version=26.10.40' -o $nosocks fake.go
    Assert-Ok 'go build fake core 1'
    go build -ldflags '-X main.version=26.10.41 -X main.testFails=yes' -o $badcfg fake.go
    Assert-Ok 'go build fake core 2'
} finally { Pop-Location }
Remove-Item -Recurse -Force $src

Write-Host '==> 5/5  the manifests (unsigned)'
Copy-Item (Join-Path $dist 'Charon-Setup-0.1.0.exe') $serve -Force
Copy-Item (Join-Path $e2e 'Charon-Setup-0.1.1.exe') $serve -Force
$realCore = Join-Path $serve 'xray-windows-amd64.exe'
Copy-Item (Join-Path $dist 'xray-windows-amd64.exe') $realCore -Force
$sign = Join-Path $e2e 'charon-sign.exe'

function New-Manifest([string]$name, [string]$version, [int]$seq, [string]$coreVersion, [string]$coreFile, [string]$app) {
    & $sign manifest -version $version -min-version '0.1.0' -sequence "$seq" -commit 'update-e2e' `
        -core-version $coreVersion -core-file $coreFile -out (Join-Path $mf "$name.json") `
        -artifact "windows-amd64:app:$(Join-Path $serve $app)" -artifact "windows-amd64:core:$coreFile"
    Assert-Ok "charon-sign manifest $name"
}
# m10: a real newer core (26.10.31) for the core that is running (26.10.21)
New-Manifest 'm10' '0.1.0' 10 '26.10.31' $realCore 'Charon-Setup-0.1.0.exe'
# m11: a core that takes the config but never opens its SOCKS port: handshake fails, rollback
New-Manifest 'm11' '0.1.0' 11 '26.10.40' $nosocks 'Charon-Setup-0.1.0.exe'
# m12: a core that rejects the config: the config check refuses it before any swap
New-Manifest 'm12' '0.1.0' 12 '26.10.41' $badcfg 'Charon-Setup-0.1.0.exe'
# m13: the app update to 0.1.1 (its installer carries the pinned core 26.10.31)
New-Manifest 'm13' '0.1.1' 13 '26.10.31' $realCore 'Charon-Setup-0.1.1.exe'
# m14: the same release one step later, to see that nothing is offered after the update
New-Manifest 'm14' '0.1.1' 14 '26.10.31' $realCore 'Charon-Setup-0.1.1.exe'

Write-Host ''
Write-Host "Done: $e2e" -ForegroundColor Green
Write-Host 'Next, from a normal PowerShell, sign the manifests with the offline release key:'
Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot\m2-update-e2e-sign.ps1 -KeyPath <path of the private key file>"
