import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../state/toast_activation.dart';
import '../state/tray_toast.dart';

/// The name Windows shows over a toast and files it under, registered for the
/// current user in [WindowsToaster.ensureRegistered].
const toastAppId = 'Charon.Desktop';

String _esc(String s) {
  final b = StringBuffer();
  for (final c in s.runes) {
    if (c < 0x20 && c != 0x09 && c != 0x0A && c != 0x0D) continue; // not allowed in XML
    switch (c) {
      case 0x26:
        b.write('&amp;');
      case 0x3C:
        b.write('&lt;');
      case 0x3E:
        b.write('&gt;');
      case 0x22:
        b.write('&quot;');
      case 0x27:
        b.write('&apos;');
      default:
        b.writeCharCode(c);
    }
  }
  return b.toString();
}

/// The XML of a toast for [spec], built from its typed fields, every text
/// escaped. The buttons are links back to the app (see [ToastActivation]).
///
/// [locked] is the public version for the lock screen: no title, no server name
/// or number, no buttons, only the sentence the board allows there.
String toastXml(ToastSpec spec, {required String token, bool locked = false}) {
  final open = ToastActivation.link(ToastAction.openWindow, token: token);
  final title = locked ? 'Charon' : spec.title;
  final body = locked ? spec.publicText : spec.body;
  final buttons = locked ? const <ToastButton>[] : spec.buttons;
  final progress = locked ? null : spec.progress;
  // A toast that stays until the user acts is a "reminder", which Windows only
  // allows when it has a button to act with.
  final stays = spec.stays && buttons.isNotEmpty;

  final x = StringBuffer()
    ..write('<toast launch="${_esc(open)}" activationType="protocol"${stays ? ' scenario="reminder"' : ''}>')
    ..write('<visual><binding template="ToastGeneric">')
    ..write('<text>${_esc(title)}</text>')
    ..write('<text>${_esc(body)}</text>');
  if (progress != null) {
    x.write('<progress title="${_esc(progress.label)}" value="${progress.fraction.clamp(0.0, 1.0).toStringAsFixed(2)}" '
        'valueStringOverride="${_esc(progress.value.isEmpty ? ' ' : progress.value)}" status=" "/>');
  }
  x.write('</binding></visual>');
  if (buttons.isNotEmpty) {
    x.write('<actions>');
    for (final b in buttons) {
      final link = ToastActivation.link(b.action, serverId: b.serverId, token: token);
      x.write('<action content="${_esc(b.label)}" arguments="${_esc(link)}" activationType="protocol"/>');
    }
    x.write('</actions>');
  }
  // Sound only for the red ones, as the board says.
  x.write(spec.sound && !locked ? '<audio src="ms-winsoundevent:Notification.Default"/>' : '<audio silent="true"/>');
  x.write('</toast>');
  return x.toString();
}

/// Shows toasts through Windows PowerShell, which can reach the toast API
/// without a plugin or a line of native code. Every script is fixed text; what
/// changes (the XML, the tag, the program's path) goes in through environment
/// variables, so nothing a server is called can become part of a script.
class WindowsToaster {
  WindowsToaster({Future<int> Function(String script, Map<String, String> env)? run}) : _run = run ?? _powershell;

  final Future<int> Function(String script, Map<String, String> env) _run;

  static const _showScript = r'''
$ErrorActionPreference = 'Stop'
[void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
[void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$doc = New-Object Windows.Data.Xml.Dom.XmlDocument
$doc.LoadXml($env:CHARON_TOAST_XML)
$toast = New-Object Windows.UI.Notifications.ToastNotification $doc
$toast.Tag = $env:CHARON_TOAST_TAG
$toast.Group = 'charon'
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($env:CHARON_TOAST_APP).Show($toast)
''';

  static const _removeScript = r'''
$ErrorActionPreference = 'Stop'
[void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
[Windows.UI.Notifications.ToastNotificationManager]::History.Remove($env:CHARON_TOAST_TAG, 'charon', $env:CHARON_TOAST_APP)
''';

  // The name Windows files the toasts under, and the link `charon://` that the
  // buttons use. Both are for the current user only, so no administrator is needed.
  static const _registerScript = r'''
$ErrorActionPreference = 'Stop'
$app = "HKCU:\Software\Classes\AppUserModelId\$($env:CHARON_TOAST_APP)"
New-Item -Path $app -Force | Out-Null
Set-ItemProperty -Path $app -Name DisplayName -Value 'Charon'
$proto = 'HKCU:\Software\Classes\charon'
New-Item -Path "$proto\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path $proto -Name '(default)' -Value 'URL:Charon'
Set-ItemProperty -Path $proto -Name 'URL Protocol' -Value ''
Set-ItemProperty -Path "$proto\shell\open\command" -Name '(default)' -Value ('"' + $env:CHARON_EXE + '" "%1"')
''';

  Map<String, String> _env(Map<String, String> more) => {'CHARON_TOAST_APP': toastAppId, ...more};

  /// Registers the app name and the `charon://` link for the current user.
  Future<bool> ensureRegistered(String exePath) async =>
      await _run(_registerScript, _env({'CHARON_EXE': exePath})) == 0;

  /// Shows [xml] as the toast of [tag], in place of the one that has that tag.
  Future<bool> show(String tag, String xml) async =>
      await _run(_showScript, _env({'CHARON_TOAST_XML': xml, 'CHARON_TOAST_TAG': tag})) == 0;

  /// Takes the toast of [tag] away, from the screen and from the notification centre.
  Future<bool> remove(String tag) async => await _run(_removeScript, _env({'CHARON_TOAST_TAG': tag})) == 0;

  static Future<int> _powershell(String script, Map<String, String> env) async {
    if (!Platform.isWindows) return 1;
    try {
      // -EncodedCommand takes UTF-16 little endian base64, so no quoting can go wrong.
      final bytes = [for (final u in script.codeUnits) ...[u & 0xFF, u >> 8]];
      final p = await Process.start(
        'powershell.exe',
        ['-NoProfile', '-NonInteractive', '-EncodedCommand', base64.encode(bytes)],
        environment: env,
      );
      unawaited(p.stdout.drain<void>());
      unawaited(p.stderr.drain<void>());
      return await p.exitCode.timeout(const Duration(seconds: 20), onTimeout: () {
        p.kill();
        return 1;
      });
    } catch (_) {
      return 1;
    }
  }
}
