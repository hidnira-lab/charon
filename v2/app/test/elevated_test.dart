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
      expect(s, contains("@('x''; Remove-Item C:\\ -Recurse; ''')"));
    });

    test('saying No to the prompt is its own code', () {
      expect(elevatedScript('a.exe', const []), contains('NativeErrorCode -eq $elevationDeclined'.replaceAll(r'$elevationDeclined', '1223')));
      expect(elevationDeclined, 1223);
    });
  });
}
