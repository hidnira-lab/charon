import 'package:charon/core/external_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<Uri> opened;

  setUp(() {
    opened = [];
    ExternalLinks.opener = (u) async {
      opened.add(u);
      return true;
    };
  });

  test('opens an https link', () async {
    expect(await ExternalLinks.open('https://github.com/hidnira-lab/charon'), isTrue);
    expect(opened.single.host, 'github.com');
  });

  test('refuses everything that is not an https link', () async {
    for (final u in ['http://example.com', 'file:///C:/Windows/system32/calc.exe', 'charon://pair?h=x', 'javascript:alert(1)', 'https://', 'not a link', '']) {
      expect(await ExternalLinks.open(u), isFalse, reason: u);
    }
    expect(opened, isEmpty);
  });

  test('a failing launcher is false, not a crash', () async {
    ExternalLinks.opener = (u) async => throw StateError('no browser');
    expect(await ExternalLinks.open('https://example.com'), isFalse);
  });
}
