<#
.SYNOPSIS
    Measures what the Charon window costs (RAM, CPU, GPU, time to appear) and checks it
    against the budget of docs/performance_plan.md, section 4 (WP0).

.DESCRIPTION
    Plain PowerShell, no admin. Run it on a release build, from a machine you are not using
    for something else while it runs. Home screen, idle, not connected.

      .\perf-window.ps1 -Build      build the release first (a few minutes), then measure
      .\perf-window.ps1             measure the build that is there
      .\perf-window.ps1 -Exe X.exe  measure another build (a copy of the Release folder)
      .\perf-window.ps1 -Runs 3     three runs, the table shows each, the verdict uses the median
      .\perf-window.ps1 -Unfocused the visible sample is taken with another window (a bare form) in
                                    front, to see what the loops cost when they should be still

    Per run: start the window, note when it shows, wait for it to settle, sample the visible
    window (default 20 s), minimize it, sample again (default 12 s). CPU is of all logical
    threads (100 percent = every thread). GPU is the 3D engine of the process. RAM is the
    working set, which on an integrated GPU includes the memory the driver maps.

    Anything else running adds noise (the v1 app, a browser). The same noise on both sides of
    a comparison is fine, so compare runs made under the same conditions, and say so when
    quoting a number. The log is written next to the other M2 logs. Exit code 1 when a budget
    is missed. It starts and stops only the process it started.
#>
param(
    [string]$App = (Join-Path $PSScriptRoot '..\app'),
    [string]$Flutter = 'C:\flutter\bin\flutter.bat',
    [string]$Stage = ([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\charon-essential\charon-m2-test'))),
    [string]$Exe,
    [switch]$Build,
    [switch]$Unfocused,
    [int]$Runs = 1,
    [int]$VisibleSeconds = 20,
    [int]$MinimizedSeconds = 12,
    [int]$SettleSeconds = 6
)

$ErrorActionPreference = 'Stop'
$App = (Resolve-Path $App).Path
$logDir = Join-Path $Stage 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("perf-window-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Start-Transcript -Path $log | Out-Null

# The budget of the plan, section 4. Change it there first.
$budget = [ordered]@{
    AppearSeconds = 2.0
    VisibleRamMb  = 250
    VisibleCpu    = 3.0
    VisibleGpu    = 5.0
    MinRamMb      = 100
    MinCpu        = 0.5
}

Add-Type -Namespace Perf -Name Win -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr h, int c);
[DllImport("user32.dll")] public static extern bool IsWindowVisible(System.IntPtr h);
[DllImport("user32.dll")] public static extern System.IntPtr GetForegroundWindow();
'@

if ($Build) {
    Write-Host '=== build (release)'
    Push-Location $App
    try { & $Flutter build windows --release 2>&1 | Select-String -Pattern 'Built|error' | Select-Object -Last 3 }
    finally { Pop-Location }
}
$exe = if ($Exe) { $Exe } else { Join-Path $App 'build\windows\x64\runner\Release\charon.exe' }
if (-not (Test-Path $exe)) { throw "No release build at $exe. Run with -Build." }
if (Get-Process -Name charon -ErrorAction SilentlyContinue) { throw 'A Charon window is already running. Quit it first (the second launch would only hand over to it).' }

$logical = [Environment]::ProcessorCount

function Sample([System.Diagnostics.Process]$p, [int]$seconds) {
    $cpus = @(); $gpus = @()
    $prevCpu = $p.TotalProcessorTime.TotalSeconds; $prevT = Get-Date
    for ($k = 0; $k -lt $seconds; $k++) {
        Start-Sleep -Seconds 1
        $p.Refresh()
        $now = Get-Date; $cpu = $p.TotalProcessorTime.TotalSeconds
        $cpus += 100 * ($cpu - $prevCpu) / (($now - $prevT).TotalSeconds * $logical)
        $prevCpu = $cpu; $prevT = $now
        $g = 0
        try {
            $g = ((Get-Counter '\GPU Engine(*)\Utilization Percentage' -ErrorAction Stop).CounterSamples |
                Where-Object { $_.InstanceName -like "pid_$($p.Id)_*engtype_3D*" } | Measure-Object CookedValue -Sum).Sum
        } catch { }
        $gpus += $g
    }
    $p.Refresh()
    [pscustomobject]@{
        Cpu = ($cpus | Measure-Object -Average).Average
        Gpu = ($gpus | Measure-Object -Average).Average
        RamMb = $p.WorkingSet64 / 1MB
    }
}

function Median($values) {
    $s = @($values | Sort-Object)
    if ($s.Count -eq 0) { return 0.0 }
    $i = [int][math]::Floor(($s.Count - 1) / 2)
    return [double]$s[$i]
}

$rows = @()
for ($run = 1; $run -le $Runs; $run++) {
    Write-Host "=== run $run of $Runs"
    $t0 = Get-Date
    $p = Start-Process -FilePath $exe -PassThru
    try {
        $appear = $null
        for ($k = 0; $k -lt 300; $k++) {
            $p.Refresh()
            if ($p.MainWindowHandle -ne 0 -and [Perf.Win]::IsWindowVisible($p.MainWindowHandle)) { $appear = ((Get-Date) - $t0).TotalSeconds; break }
            Start-Sleep -Milliseconds 50
        }
        if ($null -eq $appear) { throw 'The window never showed.' }
        Start-Sleep -Seconds $SettleSeconds
        $other = $null
        if ($Unfocused) {
            $other = Start-Process powershell -PassThru -ArgumentList '-NoProfile', '-Command', 'Add-Type -AssemblyName System.Windows.Forms; [void][Windows.Forms.Application]::Run((New-Object Windows.Forms.Form))'; Start-Sleep -Seconds 3
            for ($try = 0; $try -lt 5 -and [Perf.Win]::GetForegroundWindow() -eq $p.MainWindowHandle; $try++) {
                [void](New-Object -ComObject WScript.Shell).AppActivate($other.Id); Start-Sleep -Seconds 1
            }
            if ([Perf.Win]::GetForegroundWindow() -eq $p.MainWindowHandle) { Write-Warning 'The focus stayed on Charon: this run is NOT an unfocused sample.' }
            Start-Sleep -Seconds 1
        }
        try { $vis = Sample $p $VisibleSeconds }
        finally { if ($other) { Stop-Process -Id $other.Id -Force -ErrorAction SilentlyContinue } }
        [void][Perf.Win]::ShowWindow($p.MainWindowHandle, 6)   # SW_MINIMIZE
        Start-Sleep -Seconds 2
        $min = Sample $p $MinimizedSeconds
        $rows += [pscustomobject]@{
            Run = $run; Appear = $appear
            VisCpu = $vis.Cpu; VisGpu = $vis.Gpu; VisRam = $vis.RamMb
            MinCpu = $min.Cpu; MinGpu = $min.Gpu; MinRam = $min.RamMb
        }
    }
    finally {
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        [void]$p.WaitForExit(8000)
    }
}

Write-Host ''
Write-Host ('{0,-4} {1,8} | {2,8} {3,8} {4,9} | {5,8} {6,8} {7,9}' -f 'run', 'appear s', 'vis CPU%', 'vis GPU%', 'vis RAM', 'min CPU%', 'min GPU%', 'min RAM')
foreach ($r in $rows) {
    Write-Host ('{0,-4} {1,8:N1} | {2,8:N1} {3,8:N1} {4,8:N0}M | {5,8:N1} {6,8:N1} {7,8:N0}M' -f $r.Run, $r.Appear, $r.VisCpu, $r.VisGpu, $r.VisRam, $r.MinCpu, $r.MinGpu, $r.MinRam)
}

$m = [ordered]@{
    AppearSeconds = (Median @($rows.Appear | ForEach-Object { [double]$_ }))
    VisibleRamMb  = (Median @($rows.VisRam | ForEach-Object { [double]$_ }))
    VisibleCpu    = (Median @($rows.VisCpu | ForEach-Object { [double]$_ }))
    VisibleGpu    = (Median @($rows.VisGpu | ForEach-Object { [double]$_ }))
    MinRamMb      = (Median @($rows.MinRam | ForEach-Object { [double]$_ }))
    MinCpu        = (Median @($rows.MinCpu | ForEach-Object { [double]$_ }))
}
Write-Host ''
Write-Host "Verdict on the median of $Runs run(s), against the budget:"
$failed = 0
foreach ($k in $budget.Keys) {
    $ok = $m[$k] -le $budget[$k]
    if (-not $ok) { $failed++ }
    Write-Host ('  {0,-4} {1,-14} {2,8:N1}  (budget {3})' -f ($(if ($ok) { 'PASS' } else { 'FAIL' })), $k, $m[$k], $budget[$k])
}
Write-Host ("Machine: {0} logical threads, {1:N1} GB RAM. Log: {2}" -f $logical, ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB), $log)
Stop-Transcript | Out-Null
if ($failed -gt 0) { exit 1 }
