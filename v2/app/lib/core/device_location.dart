import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// What asking the device for its position came to.
enum LocationOutcome {
  /// A position came back.
  found,

  /// Windows location is off for this app or for the PC, so nothing was read.
  denied,

  /// No position, and no word about permission: no sensor, no fix in time, or
  /// not a system that can tell.
  unavailable,
}

/// The answer. [lat] and [lon] mean something only when [outcome] is
/// [LocationOutcome.found]. The position is used once, to pick a city from the
/// offline table, and is never stored or sent anywhere.
typedef LocationResult = ({LocationOutcome outcome, double lat, double lon});

/// Asks the device where it is. A function, so the controller does not know
/// about Windows and a test can answer for it.
typedef LocationReader = Future<LocationResult> Function();

const _none = (outcome: LocationOutcome.unavailable, lat: 0.0, lon: 0.0);

/// A fixed script, nothing from the user goes into it. It uses the Windows
/// Location platform through `System.Device.Location`, so Charon needs no
/// package for it, and it asks the system the same question the Windows
/// privacy page governs. It prints `found <lat> <lon>`, `denied` or
/// `unavailable`.
const _script = r'''
$ErrorActionPreference = 'Stop'
try {
  Add-Type -AssemblyName System.Device
  $w = New-Object System.Device.Location.GeoCoordinateWatcher([System.Device.Location.GeoPositionAccuracy]::Default)
  [void]$w.TryStart($false, [TimeSpan]::FromSeconds(3))
  $sw = [Diagnostics.Stopwatch]::StartNew()
  while ($sw.Elapsed.TotalSeconds -lt 10 -and $w.Status -ne 'Ready' -and $w.Status -ne 'Disabled') { Start-Sleep -Milliseconds 200 }
  $l = $w.Position.Location
  if ($w.Status -eq 'Ready' -and -not $l.IsUnknown) {
    [string]::Format([cultureinfo]::InvariantCulture, 'found {0} {1}', $l.Latitude, $l.Longitude)
  } elseif ($w.Permission -eq 'Denied' -or $w.Status -eq 'Disabled') {
    'denied'
  } else {
    'unavailable'
  }
} catch {
  'unavailable'
}
''';

/// Reads what [_script] printed. Anything unexpected is "unavailable".
LocationResult parseLocationOutput(String out) {
  for (final line in const LineSplitter().convert(out)) {
    final t = line.trim();
    if (t == 'denied') return (outcome: LocationOutcome.denied, lat: 0.0, lon: 0.0);
    final m = RegExp(r'^found (-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)$').firstMatch(t);
    if (m != null) {
      final lat = double.parse(m.group(1)!), lon = double.parse(m.group(2)!);
      if (lat.abs() <= 90 && lon.abs() <= 180) return (outcome: LocationOutcome.found, lat: lat, lon: lon);
    }
  }
  return _none;
}

/// The Windows reader. It takes under a second on a PC with location on, and
/// gives up after 15 seconds.
Future<LocationResult> readWindowsLocation() async {
  if (!Platform.isWindows) return _none;
  try {
    // -EncodedCommand takes UTF-16 little endian base64, so no quoting can go wrong.
    final bytes = [for (final u in _script.codeUnits) ...[u & 0xFF, u >> 8]];
    final p = await Process.start('powershell.exe', ['-NoProfile', '-NonInteractive', '-EncodedCommand', base64.encode(bytes)]);
    final out = p.stdout.transform(utf8.decoder).join();
    unawaited(p.stderr.drain<void>());
    final text = await out.timeout(const Duration(seconds: 15), onTimeout: () {
      p.kill();
      return '';
    });
    return parseLocationOutput(text);
  } catch (_) {
    return _none;
  }
}
