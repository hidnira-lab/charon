import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Append-only `crash.log` + a Windows relaunch watchdog.
///
/// Why: the app has been reported to vanish occasionally with no OS crash
/// record. A `[start]` line with no matching `[exit clean]` after it means the
/// process died abruptly (crash, kill, power loss) - exactly the evidence we
/// were missing. Rust panics write to the same file (see the panic hook in
/// `CharonBridge::new`).
class CrashLog {
  static File? _log;
  static File? _cleanFlag;

  static Future<void> init(List<String> args) async {
    try {
      final dir = await getApplicationSupportDirectory();
      _log = File('${dir.path}/crash.log');
      _cleanFlag = File('${dir.path}/clean_exit.flag');
      // Keep the file small: drop it once it passes ~256 KB.
      if (await _log!.exists() && await _log!.length() > 256 * 1024) {
        await _log!.delete();
      }
      // A stale flag from a previous run would make the watchdog think this
      // run already exited cleanly.
      if (await _cleanFlag!.exists()) await _cleanFlag!.delete();
      write('[start] pid=$pid args=$args');
    } catch (_) {}

    FlutterError.onError = (details) {
      write('[flutter-error] ${details.exceptionAsString()}\n${details.stack}');
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      write('[async-error] $error\n$stack');
      return true; // handled - don't take the app down for a stray async error
    };
  }

  static void write(String message) {
    try {
      _log?.writeAsStringSync('${DateTime.now().toIso8601String()} $message\n',
          mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  /// Call right before a deliberate `exit(0)`: tells both the log and the
  /// watchdog that this exit was intentional.
  static void markCleanExit() {
    write('[exit clean]');
    try {
      _cleanFlag?.writeAsStringSync('1', flush: true);
    } catch (_) {}
  }

  /// Windows only. Spawns a tiny detached PowerShell that waits for this
  /// process to end and, if no clean-exit flag was written, relaunches the
  /// app minimized to the tray. Inherits this process's elevated token, so no
  /// UAC prompt. Gives up after 3 relaunches in 10 minutes (crash-loop guard).
  ///
  /// NOTE for tooling: `taskkill`-ing CharonVPN.exe counts as a crash and
  /// triggers a relaunch - create `clean_exit.flag` first (or exit via the
  /// app) when you need it to stay dead, e.g. before rebuilding the exe.
  static Future<void> startWatchdog() async {
    if (!Platform.isWindows || _cleanFlag == null) return;
    String q(String s) => s.replaceAll("'", "''");
    final dir = _cleanFlag!.parent.path;
    final script = '''
\$appPid = $pid
\$exe = '${q(Platform.resolvedExecutable)}'
\$flag = '${q(_cleanFlag!.path)}'
\$hist = '${q('$dir/relaunch_history.txt')}'
try { Wait-Process -Id \$appPid -ErrorAction Stop } catch {}
if (Test-Path \$flag) { exit }
\$now = Get-Date
\$recent = @()
if (Test-Path \$hist) { \$recent = @(Get-Content \$hist | ForEach-Object { [datetime]\$_ } | Where-Object { \$_ -gt \$now.AddMinutes(-10) }) }
if (\$recent.Count -ge 3) { exit }
(\$recent + \$now) | ForEach-Object { \$_.ToString('o') } | Set-Content \$hist
Start-Sleep -Seconds 3
Start-Process -FilePath \$exe -ArgumentList '--minimized','--relaunched'
''';
    try {
      await Process.start(
        'powershell.exe',
        ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-Command', script],
        mode: ProcessStartMode.detached,
      );
      write('[watchdog] started');
    } catch (e) {
      write('[watchdog] failed to start: $e');
    }
  }
}
