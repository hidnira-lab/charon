import 'package:flutter/material.dart';

import '../../../core/external_link.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/home_controller.dart';
import '../../../theme/theme.dart';
import '../../common/glass_card.dart';
import '../../home/widgets/rail_nav.dart';
import '../../common/motion.dart';

/// The frame of the three Trust pages (Licences, Privacy and network, Export
/// diagnostics): the rail, the breadcrumb that goes back to Settings, the
/// title and a short line on the right. [child] fills the rest.
class TrustPage extends StatelessWidget {
  const TrustPage({
    super.key,
    required this.controller,
    required this.crumb,
    required this.title,
    required this.meta,
    required this.child,
    this.scroll = true,
  });

  final HomeController controller;
  final String crumb;
  final String title;
  final String meta;
  final Widget child;

  /// False when the page lays itself out to the window height (diagnostics).
  final bool scroll;

  void _back(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      controller.setTab(4); // Settings
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Row(
        children: [
          RailNav(controller: controller, selectedIndex: 4, onTabSelected: controller.setTab),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // The header, then the page, rise on arrival (mPg).
                children: [
                  Enter.page(
                    index: 0,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _back(context),
                            child: Text(
                              '> ${l10n.trustCrumbPrefix} · $crumb',
                              style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.33,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(meta, style: monoStyle(colors.text3, 11)),
                      ),
                    ],
                  )),
                  const SizedBox(height: 12),
                  Expanded(child: Enter.page(index: 1, child: scroll ? SingleChildScrollView(child: child) : child)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A link of the board ("Full text ↗", "Threat model ↗"). It opens [url] in the
/// browser. With no [url] it is drawn dimmed and cannot be pressed.
class TrustLink extends StatelessWidget {
  const TrustLink(this.label, {super.key, this.url, this.pill = false});

  final String label;

  /// An https address. [ExternalLinks] refuses anything else.
  final String? url;

  /// The outlined pill of the Privacy page, instead of the plain accent text.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final text = Text(
      label,
      style: monoStyle(pill ? colors.text : colors.accentText, pill ? 12 : 11, bold: true),
    );
    final body = pill
        ? Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: colors.controlBorder),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [text]),
          )
        : text;
    final target = url;
    if (target == null) return Opacity(opacity: 0.4, child: body);
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => ExternalLinks.open(target),
        borderRadius: BorderRadius.circular(pill ? 999 : 4),
        child: body,
      ),
    );
  }
}
