import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;

/// The exit code [runElevated] returns when the person said No to the UAC
/// prompt (Windows error 1223, "The operation was canceled by the user").
const elevationDeclined = 1223;

/// The PowerShell that starts [exe] with [args] as an administrator, waits for
/// it and hands on its exit code. `Start-Process -Verb RunAs` is what raises the
/// UAC prompt: `Process.run` cannot, it can only start a program with the rights
/// the window already has.
///
/// Every value is a single quoted PowerShell string, so nothing in a path or an
/// argument is read as code.
String elevatedScript(String exe, List<String> args) {
  String q(String s) => "'${s.replaceAll("'", "''")}'";
  final argList = args.isEmpty ? '' : ' -ArgumentList @(${args.map(q).join(',')})';
  return r'$ErrorActionPreference = "Stop"; '
      'try { \$p = Start-Process -FilePath ${q(exe)}$argList -Verb RunAs -Wait -PassThru; exit \$p.ExitCode } '
      'catch { $elevationCatch }';
}

/// What the `catch` of [elevatedScript] does with the error of `Start-Process`.
/// Windows PowerShell wraps the Win32 error of a refused prompt in another
/// exception (InvalidOperationException around a Win32Exception), so
/// `$_.Exception.NativeErrorCode` is empty and a real test answered 1 instead of
/// 1223. The chain is walked until a Win32Exception is found, and its code is
/// what counts. The English words of Windows ("canceled by the user") are a second
/// way to know, in case the exception has another shape than that chain.
@visibleForTesting
const elevationCatch = r'$e = $_.Exception; $c = 0; '
    r'while ($e) { if ($e -is [System.ComponentModel.Win32Exception]) { $c = $e.NativeErrorCode; break }; $e = $e.InnerException }; '
    r'if ($c -eq 0 -and $_.Exception.Message -match "canceled by the user") { $c = 1223 }; '
    'if (\$c -eq $elevationDeclined) { exit $elevationDeclined }; exit 1';

/// The folder of the running program, where Charon's own tools sit next to the
/// window (`charon-release.exe`, the installer).
String get _programFolder => File(Platform.resolvedExecutable).parent.path;

/// Runs [exe] as an administrator and returns its exit code, or
/// [elevationDeclined] when the UAC prompt was refused. A name without a folder
/// is looked up next to the running program, never on the PATH: this is a
/// program that runs with full rights.
Future<int> runElevated(String exe, List<String> args) async {
  final path = exe.contains(RegExp(r'[\\/]')) ? exe : '$_programFolder${Platform.pathSeparator}$exe';
  final result = await Process.run('powershell.exe', [
    '-NoProfile',
    '-NonInteractive',
    '-ExecutionPolicy',
    'Bypass',
    '-WindowStyle',
    'Hidden',
    '-Command',
    elevatedScript(path, args),
  ]);
  return result.exitCode;
}
