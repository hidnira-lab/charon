import 'dart:io';

import 'package:charon/core/elevated.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('elevatedScript', () {
    test('asks for administrator rights, waits, and hands on the exit code', () {
      final s = elevatedScript(r'C:\Program Files\Charon\charon-release.exe', const []);
      expect(s, contains('Start-Process'));
      expect(s, contains('-Verb RunAs'));
      expect(s, contains('-Wait'));
      expect(s, contains(r'exit $p.ExitCode'));
      expect(s, contains("-FilePath 'C:\\Program Files\\Charon\\charon-release.exe'"));
    });

    test('no arguments means no -ArgumentList (an empty list is an error in PowerShell)', () {
      expect(elevatedScript('a.exe', const []), isNot(contains('-ArgumentList')));
    });

    test('arguments are single quoted items of one list', () {
      expect(elevatedScript('a.exe', const ['stop', 'charon']), contains("-ArgumentList @('stop','charon')"));
    });

    test('a quote in a path or an argument cannot end the string and run code', () {
      final s = elevatedScript("C:\\it's\\a.exe", const ["x'; Remove-Item C:\\ -Recurse; '"]);
      expect(s, contains("-FilePath 'C:\\it''s\\a.exe'"));
      // The argument has spaces, so it also gets the double quotes of a command line.
      expect(s, contains("@('\"x''; Remove-Item C:\\ -Recurse; ''\"')"));
    });

    test('an argument with spaces gets the double quotes Start-Process does not add', () {
      expect(windowsArg('stop'), 'stop');
      expect(windowsArg(r'C:\Program Files\Charon\install.ps1'), r'"C:\Program Files\Charon\install.ps1"');
      expect(windowsArg(''), '""');
      expect(windowsArg(r'a "b" c'), r'"a \"b\" c"');
      expect(windowsArg(r'C:\dir with space\'), r'"C:\dir with space\\"'); // a backslash before the closing quote is doubled
      expect(argumentList(['-File', r'C:\Program Files\x.ps1']), r'''@('-File','"C:\Program Files\x.ps1"')''');
    });

    test('the script keeps the catch that tells a refusal from a failure', () {
      expect(elevatedScript('a.exe', const []), contains(elevationCatch));
      expect(elevationDeclined, 1223);
    });
  });

  // The words of the script are not enough: the first version had the right words and
  // answered 1 to a real "No". These run the catch itself, in PowerShell, on the error
  // that Start-Process raises (an InvalidOperationException around a Win32Exception).
  group('the catch of the script, run for real', () {
    Future<int> answerTo(String thrown) async {
      final r = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'try { $thrown } catch { $elevationCatch }',
      ]);
      return r.exitCode;
    }

    const win32 = '[System.ComponentModel.Win32Exception]::new(1223)';

    test('a Win32Exception inside another exception (what Windows PowerShell raises) is 1223', () async {
      expect(await answerTo('throw [System.InvalidOperationException]::new("wrapped", $win32)'), 1223);
    });

    test('a bare Win32Exception with 1223 is 1223', () async {
      expect(await answerTo('throw $win32'), 1223);
    });

    // The bug of the first Repair: the script path has spaces (Program Files), and
    // Start-Process does not quote the items of -ArgumentList. Same call as the script
    // of the window, without -Verb RunAs (a test cannot answer a prompt).
    test('a script in a folder with spaces is found, and gets its switch', () async {
      final dir = await Directory.systemTemp.createTemp('charon elevated test ');
      addTearDown(() => dir.delete(recursive: true));
      final script = File('${dir.path}${Platform.pathSeparator}install copy.ps1');
      await script.writeAsString('param([switch]\$Repair)\r\nif (\$Repair) { exit 7 } else { exit 3 }\r\n');
      final args = argumentList(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script.path, '-Repair']);
      final r = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'try { \$p = Start-Process -FilePath powershell.exe -ArgumentList $args -Wait -PassThru; exit \$p.ExitCode } catch { exit 99 }',
      ]);
      expect(r.exitCode, 7, reason: '${r.stdout}${r.stderr}');
    });

    test('the words of Windows alone are enough, when the exception has another shape', () async {
      expect(await answerTo('throw "This command cannot be run due to the error: The operation was canceled by the user."'), 1223);
    });

    test('another Win32 error, and an error that is not Win32, is 1', () async {
      expect(await answerTo('throw [System.ComponentModel.Win32Exception]::new(5)'), 1);
      expect(await answerTo('throw "something else"'), 1);
    });
  }, skip: Platform.isWindows ? false : 'PowerShell of Windows');
}
