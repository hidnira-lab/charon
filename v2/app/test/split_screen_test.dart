import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/main.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/theme/theme.dart';
import 'package:charon/ui/split/rule_validator.dart';
import 'package:charon/ui/split/split_screen.dart';
import 'package:charon/ui/split/widgets/composer_card.dart';
import 'package:charon/ui/split/widgets/pending_banner.dart';
import 'package:charon/ui/split/widgets/route_map_card.dart';
import 'package:charon/ui/split/widgets/rules_list_card.dart';
import 'package:charon/ui/split/widgets/windows_info_card.dart';

void main() {
  setUpAll(loadAppFonts);

  group('RuleValidator unit tests', () {
    test('validates domain and CIDR inputs', () {
      expect(RuleValidator.isValidInput('example.com', RuleKind.RULE_DOMAIN), isTrue);
      expect(RuleValidator.isValidInput('*.example.com', RuleKind.RULE_DOMAIN), isTrue);
      expect(RuleValidator.isValidInput('invalid', RuleKind.RULE_DOMAIN), isFalse);
      expect(RuleValidator.isValidInput('', RuleKind.RULE_DOMAIN), isFalse);

      expect(RuleValidator.isValidInput('192.168.1.1', RuleKind.RULE_CIDR), isTrue);
      expect(RuleValidator.isValidInput('192.168.1.0/24', RuleKind.RULE_CIDR), isTrue);
      expect(RuleValidator.isValidInput('10.0.0.0/8', RuleKind.RULE_CIDR), isTrue);
      expect(RuleValidator.isValidInput('256.0.0.1', RuleKind.RULE_CIDR), isFalse);
      expect(RuleValidator.isValidInput('192.168.1.0/33', RuleKind.RULE_CIDR), isFalse);
      expect(RuleValidator.isValidInput('not-an-ip', RuleKind.RULE_CIDR), isFalse);
    });

    test('detects domain conflicts and overlaps', () {
      final existing = [
        Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
        Rule(kind: RuleKind.RULE_DOMAIN, value: 'charon.org', includeSubdomains: false),
      ];

      expect(
        RuleValidator.findConflict('sub.example.com', RuleKind.RULE_DOMAIN, existing),
        '*.example.com',
      );
      expect(
        RuleValidator.findConflict('example.com', RuleKind.RULE_DOMAIN, existing),
        '*.example.com',
      );
      expect(
        RuleValidator.findConflict('charon.org', RuleKind.RULE_DOMAIN, existing),
        'charon.org',
      );
      expect(
        RuleValidator.findConflict('other.org', RuleKind.RULE_DOMAIN, existing),
        isNull,
      );
    });

    test('detects IP and CIDR conflicts and overlaps', () {
      final existing = [
        Rule(kind: RuleKind.RULE_CIDR, value: '192.168.1.0/24'),
        Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.7'),
      ];

      expect(
        RuleValidator.findConflict('192.168.1.5', RuleKind.RULE_CIDR, existing),
        '192.168.1.0/24',
      );
      expect(
        RuleValidator.findConflict('192.168.0.0/16', RuleKind.RULE_CIDR, existing),
        '192.168.1.0/24',
      );
      expect(
        RuleValidator.findConflict('198.51.100.7', RuleKind.RULE_CIDR, existing),
        '198.51.100.7',
      );
      expect(
        RuleValidator.findConflict('10.0.0.1', RuleKind.RULE_CIDR, existing),
        isNull,
      );
    });
  });

  group('SplitScreen UI and interactions', () {
    testWidgets('renders all Split Tunnel sections and cards in 1024x768', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [
            Server(
              id: 'SRV-01',
              displayName: 'Main SG',
              address: '198.51.100.1',
            ),
          ],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
              Rule(kind: RuleKind.RULE_CIDR, value: '192.168.1.0/24'),
              Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.7'),
              Rule(kind: RuleKind.RULE_DOMAIN, value: 'media.example.org', includeSubdomains: false),
            ],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2); // Switch to Split Tunnel tab
      await tester.pumpAndSettle();

      expect(find.byType(SplitScreen), findsOneWidget);
      expect(find.byType(ComposerCard), findsOneWidget);
      expect(find.byType(RulesListCard), findsOneWidget);
      expect(find.byType(RouteMapCard), findsOneWidget);
      expect(find.byType(WindowsInfoCard), findsOneWidget);

      // Header checks
      expect(find.text('> SPLIT TUNNEL · 4 RULES'), findsOneWidget);
      expect(find.text('Split tunnel'), findsOneWidget);
      expect(find.text('choose what skips the tunnel'), findsOneWidget);

      // Composer checks
      expect(find.text('DOMAIN'), findsOneWidget);
      expect(find.text('IP / CIDR'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('RULES GO DIRECT'), findsOneWidget);
      expect(find.text('Add rule'), findsOneWidget);

      // Rules list checks
      expect(find.text('> DIRECT LIST'), findsOneWidget);
      expect(find.text('4 rules · go direct'), findsOneWidget);
      expect(find.text('*.example.com'), findsOneWidget);
      expect(find.text('192.168.1.0/24'), findsOneWidget);
      expect(find.text('198.51.100.7'), findsOneWidget);
      expect(find.text('media.example.org'), findsOneWidget);

      // Route map checks
      expect(find.text('> TUNNEL MODE'), findsOneWidget);
      expect(find.text('Tunnel all except listed'), findsOneWidget);
      expect(find.text('Tunnel only listed'), findsOneWidget);
      expect(find.text('> WHERE TRAFFIC GOES'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('THIS UNIT'), findsOneWidget);
      expect(find.text('Your network'), findsOneWidget);

      // Windows info note
      expect(find.text('> INFO · WINDOWS'), findsOneWidget);
      expect(find.text('App rules work on Android only'), findsOneWidget);
    });

    testWidgets('mode switching updates UI and preserves each mode list', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main SG')],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
            ],
            onlyListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.net', includeSubdomains: true),
              Rule(kind: RuleKind.RULE_CIDR, value: '198.51.100.0/24'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      expect(find.text('*.example.com'), findsOneWidget);
      expect(find.text('*.example.net'), findsNothing);

      // Tap "Tunnel only listed"
      await tester.tap(find.text('Tunnel only listed'));
      await tester.pumpAndSettle();

      expect(controller.splitMode, SplitMode.SPLIT_ONLY_LISTED);
      expect(find.text('*.example.net'), findsOneWidget);
      expect(find.text('198.51.100.0/24'), findsOneWidget);
      expect(find.text('*.example.com'), findsNothing);
      expect(find.text('RULES USE THE TUNNEL'), findsOneWidget);
      expect(find.text('> TUNNEL LIST'), findsOneWidget);

      // Switch back to "Tunnel all except listed"
      await tester.tap(find.text('Tunnel all except listed'));
      await tester.pumpAndSettle();

      expect(controller.splitMode, SplitMode.SPLIT_ALL_EXCEPT_LISTED);
      expect(find.text('*.example.com'), findsOneWidget);
      expect(find.text('*.example.net'), findsNothing);
    });

    testWidgets('adding and removing rules works correctly', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main SG')],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      expect(find.text('*.example.com'), findsOneWidget);

      // Add a new domain rule
      await tester.enterText(find.byType(TextField), 'charon-test.internal');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add rule'));
      await tester.pumpAndSettle();

      expect(find.text('charon-test.internal'), findsOneWidget);
      expect(controller.activeSplitRules.length, 2);

      // Remove the first rule (*.example.com)
      await tester.tap(find.byTooltip('Remove *.example.com'));
      await tester.pumpAndSettle();

      expect(find.text('*.example.com'), findsNothing);
      expect(find.text('charon-test.internal'), findsOneWidget);
      expect(controller.activeSplitRules.length, 1);
    });

    testWidgets('shows conflict error when adding overlapping rule', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main SG')],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      // Enter a subdomain of *.example.com
      await tester.enterText(find.byType(TextField), 'sub.example.com');
      await tester.pumpAndSettle();

      expect(find.textContaining("Already covered by *.example.com, rules can't overlap."), findsOneWidget);
      expect(find.textContaining('edit or remove *.example.com first'), findsOneWidget);
    });

    testWidgets('shows pending banner and marks rule pending when modified while connected', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_UP),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main SG')],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      // Add a rule while connected
      await tester.enterText(find.byType(TextField), 'newrule.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add rule'));
      await tester.pumpAndSettle();

      expect(find.byType(PendingBanner), findsOneWidget);
      expect(find.text('NEXT CONNECT'), findsOneWidget);
      expect(controller.hasPendingSplitChanges, isTrue);

      // Tap "Reconnect now"
      await tester.tap(find.text('Reconnect now'));
      await tester.pumpAndSettle();

      expect(controller.hasPendingSplitChanges, isFalse);
      expect(find.byType(PendingBanner), findsNothing);
    });

    HomeController controllerWith({
      List<Rule> rules = const [],
      Phase phase = Phase.PHASE_IDLE,
    }) =>
        HomeController(
          initialStatus: Status(phase: phase),
          initialConfig: Config(
            chosenServerId: 'SRV-01',
            servers: [Server(id: 'SRV-01', displayName: 'Main SG', countryCode: 'SG')],
            split: SplitTunnel(
              mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
              allExceptListed: rules,
            ),
          ),
        );

    testWidgets('empty list reads like the board', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = controllerWith();
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      expect(find.text('> SPLIT TUNNEL · NO RULES'), findsOneWidget);
      expect(find.text('NO RULES'), findsOneWidget); // the chip on the route map
      expect(find.text('0 rules'), findsOneWidget); // no "· go direct" when empty
      expect(find.text('No rules yet'), findsOneWidget);
      expect(find.text('SG'), findsOneWidget); // server country on the tunnel box
      expect(tester.takeException(), isNull);
    });

    testWidgets('the rule that covers the typed text is marked in the list', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = controllerWith(rules: [
        Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
        Rule(kind: RuleKind.RULE_CIDR, value: '192.168.1.0/24'),
      ]);
      await tester.pumpWidget(CharonApp(controller: controller));
      controller.setTab(2);
      await tester.pumpAndSettle();

      RulesListCard list() => tester.widget<RulesListCard>(find.byType(RulesListCard));
      expect(list().conflictWith, isNull);

      await tester.enterText(find.byType(TextField), 'sub.example.com');
      await tester.pumpAndSettle();
      expect(list().conflictWith, '*.example.com');

      // Switching mode gives another list, so the old conflict must go.
      await tester.tap(find.text('Tunnel only listed'));
      await tester.pumpAndSettle();
      expect(list().conflictWith, isNull);
      expect(find.textContaining("Already covered by"), findsNothing);
    });

    testWidgets('light theme uses the light tokens, not the dark ones', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = controllerWith(rules: [
        Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
      ]);
      await tester.pumpWidget(CharonApp(controller: controller, themeData: CharonTheme.light));
      controller.setTab(2);
      await tester.pumpAndSettle();

      final ink = tester.widget<Text>(find.text('*.example.com')).style!.color;
      expect(ink, CharonColors.light.text);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Simplified Chinese with the board words', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = controllerWith(rules: [
        Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com', includeSubdomains: true),
      ]);
      await tester.pumpWidget(CharonApp(controller: controller, locale: const Locale('zh')));
      controller.setTab(2);
      await tester.pumpAndSettle();

      expect(find.text('> 分流 · 1 条规则'), findsOneWidget);
      expect(find.text('笔记本'), findsOneWidget);
      expect(find.text('直连'), findsOneWidget);
      expect(find.byTooltip('删除 *.example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Indonesian localization without overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = HomeController(
        initialStatus: Status(phase: Phase.PHASE_IDLE),
        initialConfig: Config(
          chosenServerId: 'SRV-01',
          servers: [Server(id: 'SRV-01', displayName: 'Main SG')],
          split: SplitTunnel(
            mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
            allExceptListed: [
              Rule(kind: RuleKind.RULE_DOMAIN, value: '*.example.com'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(CharonApp(
        controller: controller,
        locale: const Locale('id'),
      ));
      controller.setTab(2);
      await tester.pumpAndSettle();

      expect(find.text('> DAFTAR LANGSUNG'), findsOneWidget);
      expect(find.text('> MODE TUNNEL'), findsOneWidget);
      expect(find.text('PERANGKAT INI'), findsOneWidget);
      expect(find.text('Jaringanmu'), findsOneWidget);
      expect(find.text('Aturan aplikasi hanya jalan di Android'), findsOneWidget);
    });
  });
}
