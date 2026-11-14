import 'dart:io';

/// The folder where the service keeps the installers it has verified (`staging` in its
/// data folder, which only the service and administrators can read or write).
String get defaultStagingDir => (Platform.environment['ProgramData'] ?? r'C:\ProgramData') + r'\Charon\staging';

/// Whether [path] is an installer that the service staged, and nothing else.
///
/// The path comes from an event of the service, over a pipe that only the installing
/// user can open, but what the window does with it is to start it with full rights, so
/// it is checked as if it could be wrong: it must be a `.exe` directly inside
/// [stagingDir] (no subfolder, no `..`, no stream name, no trailing dot or space).
/// Windows paths are not case sensitive, and `/` is the same as `\`.
bool isStagedInstaller(String path, String stagingDir) {
  final p = path.replaceAll('/', r'\');
  final dir = stagingDir.replaceAll('/', r'\').replaceAll(RegExp(r'\\+$'), '');
  if (p.isEmpty || dir.isEmpty) return false;
  if (!p.toLowerCase().startsWith('${dir.toLowerCase()}\\')) return false;
  final name = p.substring(dir.length + 1);
  if (name.isEmpty || name.contains(r'\') || name.contains(':') || name == '.' || name == '..') return false;
  if (name.endsWith('.') || name.endsWith(' ')) return false;
  if (name.contains(RegExp(r'[<>"|?*\x00-\x1f]'))) return false;
  return name.toLowerCase().endsWith('.exe');
}
