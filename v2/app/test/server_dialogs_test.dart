import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/l10n/generated/app_localizations.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/servers/widgets/add_server_dialog.dart';
import 'package:charon/ui/servers/widgets/edit_server_dialog.dart';
import 'package:charon/ui/settings/widgets/charon_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

const _pbk = 'Zx9K3mP8Q2wE4rT6yU1iO5pA7sD9fG2hJ4kL6zX8cV0=';
const _link =
    'vless://8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b@198.51.100.7:443?security=reality&sni=example.com&pbk=$_pbk&sid=6ba8&flow=xtls-rprx-vision';
const _json =
    '{"outbounds":[{"tag":"proxy","protocol":"vless","settings":{"vnext":[{"address":"198.51.100.9","port":443,"users":[{"id":"abc","flow":"xtls-rprx-vision"}]}]},"streamSettings":{"network":"tcp","security":"reality","realitySettings":{"serverName":"example.com","publicKey":"$_pbk","shortId":"6ba8"}}}]}';

Server _saved(String id, String address) => Server(
      id: id,
      displayName: 'Home VPS',
      address: address,
      port: 443,
      reality: Reality(publicKey: _pbk),
    );

Widget _app(Widget Function(BuildContext) opener, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: CharonTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: opener)),
    );

Future<void> _open(WidgetTester tester, List<Server> existing, void Function(AddServerOutcome?) done,
    {Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(
    (context) => TextButton(
      onPressed: () async => done(await AddServerDialog.show(context, existing)),
      child: const Text('open'),
    ),
    locale: locale,
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _saveButton() => find.widgetWithText(InkWell, 'Save server');

bool _saveEnabled(WidgetTester tester) => tester.widget<InkWell>(_saveButton()).onTap != null;

Server _full({String name = 'Home VPS', String country = 'SG', QuotaPlan? quota}) => Server(
      id: 'SRV-01',
      displayName: name,
      address: '198.51.100.7',
      port: 443,
      uuid: '8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b',
      flow: 'xtls-rprx-vision',
      countryCode: country,
      reality: Reality(publicKey: _pbk, shortId: '6ba8', serverName: 'example.com'),
      quota: quota,
    );

Future<void> _openEdit(WidgetTester tester, Server server, void Function(Server?) done,
    {bool carrying = false, Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(
    (context) => TextButton(
      onPressed: () async => done(await EditServerDialog.show(context, server, carryingTraffic: carrying)),
      child: const Text('open'),
    ),
    locale: locale,
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _combo() => find.byType(PopupMenuButton<String>);

Finder _saveChanges() => find.widgetWithText(InkWell, 'Save changes');

void main() {
  setUpAll(loadAppFonts);

  group('Add server dialog', () {
    testWidgets('starts empty with Save off and the two tabs of the board', (tester) async {
      await _open(tester, [_saved('SRV-01', '203.0.113.1')], (_) {});
      expect(find.text('> SERVERS · ADD'), findsOneWidget);
      expect(find.text('Add a server'), findsOneWidget);
      expect(find.text('Import vless:// link'), findsOneWidget);
      expect(find.text('Paste config'), findsOneWidget);
      expect(find.text('VLESS LINK'), findsOneWidget);
      expect(_saveEnabled(tester), isFalse);
    });

    testWidgets('a good link shows the preview and saves under the address when no name is given', (tester) async {
      AddServerOutcome? out;
      await _open(tester, [_saved('SRV-01', '203.0.113.1')], (o) => out = o);
      await tester.enterText(find.byType(TextField).first, _link);
      await tester.pump();

      expect(find.text('5 of 5 fields ok'), findsOneWidget);
      expect(find.text('198.51.100.7:443'), findsOneWidget);
      expect(find.text('vision'), findsOneWidget);
      expect(find.text('✓ · 6ba8'), findsOneWidget);
      expect(find.textContaining('becomes SRV-02 · #2 in failover order · country not known'), findsOneWidget);
      expect(_saveEnabled(tester), isTrue);

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      final added = (out as ServerAdded).server;
      expect(added.id, 'SRV-02');
      expect(added.displayName, '198.51.100.7');
      expect(added.countryCode, isEmpty);
    });

    testWidgets('a name typed in the preview wins', (tester) async {
      AddServerOutcome? out;
      await _open(tester, const [], (o) => out = o);
      await tester.enterText(find.byType(TextField).first, _link);
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Tokyo');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect((out as ServerAdded).server.displayName, 'Tokyo');
    });

    testWidgets('a vmess link is named plainly and cannot be saved', (tester) async {
      await _open(tester, const [], (_) {});
      await tester.enterText(find.byType(TextField).first, 'vmess://eyJ2IjoiMiJ9');
      await tester.pump();
      expect(find.text('Charon only speaks VLESS with Reality. This link is another kind.'), findsOneWidget);
      expect(find.textContaining('hysteria2 are not supported'), findsOneWidget);
      expect(find.text('5 of 5 fields ok'), findsNothing);
      expect(_saveEnabled(tester), isFalse);
    });

    testWidgets('a link without pbk says which key is missing', (tester) async {
      await _open(tester, const [], (_) {});
      await tester.enterText(
          find.byType(TextField).first, 'vless://8f3c1a2b@198.51.100.7:443?security=reality&sni=example.com');
      await tester.pump();
      expect(find.text('Missing pbk, the Reality public key.'), findsOneWidget);
      expect(find.textContaining('copy the link again from your panel'), findsOneWidget);
    });

    testWidgets('a duplicate shows the banner and offers to edit the saved server', (tester) async {
      AddServerOutcome? out;
      await _open(tester, [_saved('SRV-01', '198.51.100.7')], (o) => out = o);
      await tester.enterText(find.byType(TextField).first, _link);
      await tester.pump();

      expect(find.text('This is already SRV-01 · Home VPS'), findsOneWidget);
      expect(find.text('5 of 5 fields ok'), findsNothing);
      expect(_saveEnabled(tester), isFalse);

      await tester.tap(find.text('Edit SRV-01 →'));
      await tester.pumpAndSettle();
      expect((out as EditRequested).id, 'SRV-01');
    });

    testWidgets('the Paste config tab reads an xray config and keeps the link tab text', (tester) async {
      AddServerOutcome? out;
      await _open(tester, const [], (o) => out = o);
      await tester.enterText(find.byType(TextField).first, _link);
      await tester.pump();

      await tester.tap(find.text('Paste config'));
      await tester.pumpAndSettle();
      expect(find.text('XRAY CONFIG · JSON'), findsOneWidget);
      expect(find.text('5 of 5 fields ok'), findsNothing); // the config box is still empty

      await tester.enterText(find.byType(TextField).first, _json);
      await tester.pump();
      expect(find.text('valid · 1 outbound'), findsOneWidget);
      expect(find.text('> READ FROM THE CONFIG · NO NAME IN IT'), findsOneWidget);
      expect(find.text('198.51.100.9:443'), findsOneWidget);

      await tester.tap(find.text('Import vless:// link'));
      await tester.pumpAndSettle();
      expect(find.text('198.51.100.7:443'), findsOneWidget);

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect((out as ServerAdded).server.address, '198.51.100.7');
    });

    testWidgets('a vmess config names the protocol in the editor header', (tester) async {
      await _open(tester, const [], (_) {});
      await tester.tap(find.text('Paste config'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '{"protocol":"vmess"}');
      await tester.pump();
      expect(find.text('protocol is vmess, not vless'), findsOneWidget);
      expect(_saveEnabled(tester), isFalse);
    });

    testWidgets('a link that carries a name fills the name field', (tester) async {
      AddServerOutcome? out;
      await _open(tester, const [], (o) => out = o);
      await tester.enterText(find.byType(TextField).first, '$_link#Seoul%20VPS');
      await tester.pump();
      expect(find.text('> READ FROM THE LINK'), findsOneWidget);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect((out as ServerAdded).server.displayName, 'Seoul VPS');
    });

    testWidgets('speaks Indonesian', (tester) async {
      await _open(tester, const [], (_) {}, locale: const Locale('id'));
      expect(find.text('> SERVER · TAMBAH'), findsOneWidget);
      expect(find.text('Tambah server'), findsOneWidget);
      expect(find.text('Impor link vless://'), findsOneWidget);
    });
  });

  group('Edit server dialog', () {
    testWidgets('shows the board: name, country, read only connection, quota', (tester) async {
      await _openEdit(tester, _full(), (_) {});
      expect(find.text('> SERVERS · EDIT SRV-01'), findsOneWidget);
      expect(find.text('Edit Home VPS'), findsOneWidget);
      expect(find.descendant(of: _combo(), matching: find.text('Singapore')), findsOneWidget);
      expect(find.text('198.51.100.7:443'), findsOneWidget);
      expect(find.text('Zx9…'), findsOneWidget); // the public key never in full
      expect(find.text('8f3c… hidden'), findsOneWidget);
      expect(find.textContaining(_pbk), findsNothing);
      expect(find.textContaining('8f3c1a2b'), findsNothing);
      expect(find.text('off · Home only shows traffic, no limit'), findsOneWidget);
      expect(find.textContaining('is carrying your traffic'), findsNothing);
    });

    testWidgets('a name equal to the country name starts as an empty field', (tester) async {
      await _openEdit(tester, _full(name: 'Singapore'), (_) {});
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('names the server carrying traffic', (tester) async {
      await _openEdit(tester, _full(), (_) {}, carrying: true);
      expect(find.text('SRV-01 is carrying your traffic right now. Changes apply on the next connect.'), findsOneWidget);
    });

    testWidgets('saves a new name and keeps the connection fields as they were', (tester) async {
      Server? out;
      await _openEdit(tester, _full(), (s) => out = s);
      await tester.enterText(find.byType(TextField).first, 'Tokyo box');
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.displayName, 'Tokyo box');
      expect(out!.address, '198.51.100.7');
      expect(out!.uuid, '8f3c1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b');
      expect(out!.reality.publicKey, _pbk);
      expect(out!.id, 'SRV-01');
      expect(out!.hasQuota(), isFalse);
    });

    testWidgets('an empty name becomes the country name', (tester) async {
      Server? out;
      await _openEdit(tester, _full(), (s) => out = s);
      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.displayName, 'Singapore');
    });

    testWidgets('picking another country changes the code and an empty name follows it', (tester) async {
      Server? out;
      await _openEdit(tester, _full(), (s) => out = s);
      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(_combo());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Japan'), 80, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Japan').last);
      await tester.pumpAndSettle();
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.countryCode, 'JP');
      expect(out!.displayName, 'Japan');
    });

    testWidgets('a server with no country can be given one', (tester) async {
      Server? out;
      await _openEdit(tester, _full(country: ''), (s) => out = s);
      expect(find.text('not set'), findsOneWidget);
      await tester.tap(_combo());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('United States'), 80, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.countryCode, 'US');
    });

    testWidgets('quota on shows the two fields and writes the plan, keeping the counts mode', (tester) async {
      Server? out;
      final plan = QuotaPlan(capGb: 1000, billingDay: 3, counts: CountsMode.COUNTS_IN_AND_OUT);
      await _openEdit(tester, _full(quota: plan), (s) => out = s);
      expect(find.text('PLAN CAP'), findsOneWidget);
      expect(find.text('RESETS ON'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '1000'), '2000');
      await tester.enterText(find.widgetWithText(TextField, '3'), '14');
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.quota.capGb, 2000);
      expect(out!.quota.billingDay, 14);
      expect(out!.quota.counts, CountsMode.COUNTS_IN_AND_OUT);
    });

    testWidgets('the switch on starts at 2000 GB on day 1', (tester) async {
      Server? out;
      await _openEdit(tester, _full(), (s) => out = s);
      await tester.tap(find.byType(CharonSwitch));
      await tester.pumpAndSettle();
      expect(find.text('Home shows how much of the plan is left this cycle'), findsOneWidget);
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.quota.capGb, 2000);
      expect(out!.quota.billingDay, 1);
    });

    testWidgets('the switch off removes the plan', (tester) async {
      Server? out;
      await _openEdit(tester, _full(quota: QuotaPlan(capGb: 1000, billingDay: 3)), (s) => out = s);
      await tester.tap(find.byType(CharonSwitch));
      await tester.pumpAndSettle();
      await tester.tap(_saveChanges());
      await tester.pumpAndSettle();
      expect(out!.hasQuota(), isFalse);
    });

    testWidgets('an invalid quota number keeps Save off', (tester) async {
      await _openEdit(tester, _full(quota: QuotaPlan(capGb: 1000, billingDay: 3)), (_) {});
      await tester.enterText(find.widgetWithText(TextField, '3'), '40');
      await tester.pump();
      expect(tester.widget<InkWell>(_saveChanges()).onTap, isNull);
      await tester.enterText(find.widgetWithText(TextField, '40'), '28');
      await tester.pump();
      expect(tester.widget<InkWell>(_saveChanges()).onTap, isNotNull);
    });

    testWidgets('cancel returns nothing', (tester) async {
      Server? out = _full();
      await _openEdit(tester, _full(), (s) => out = s);
      await tester.tap(find.widgetWithText(InkWell, 'Cancel'));
      await tester.pumpAndSettle();
      expect(out, isNull);
    });

    testWidgets('speaks Chinese', (tester) async {
      await _openEdit(tester, _full(), (_) {}, locale: const Locale('zh'));
      expect(find.text('> 服务器 · 编辑 SRV-01'), findsOneWidget);
      expect(find.descendant(of: _combo(), matching: find.text('新加坡')), findsOneWidget);
    });
  });
}
