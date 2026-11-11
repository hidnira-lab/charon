import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/app_info.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import 'widgets/trust_page.dart';

const _gplText = 'GNU GENERAL PUBLIC LICENSE\n'
    'Version 3, 29 June 2007\n\n'
    'Copyright (C) 2007 Free Software Foundation, Inc.\n'
    'Everyone is permitted to copy and distribute verbatim copies of this '
    'license document, but changing it is not allowed.';

const _mplText = 'Mozilla Public License Version 2.0\n\n'
    '1. Definitions\n'
    '1.1. "Contributor" means each individual or legal entity that creates, '
    'contributes to the creation of, or owns Covered Software.';

const _oflText = 'SIL OPEN FONT LICENSE Version 1.1\n\n'
    'The fonts can be bundled, embedded and redistributed with any software.';

/// One row of the list. The names, the licence chips and the licence texts are
/// not translated: they are names and legal text. [chip] null means the terms
/// are still to be confirmed.
class _Lic {
  const _Lic(this.name, this.chip, this.sub, this.text, this.link);

  final String name;
  final String? chip;
  final String sub;
  final String text;
  final String link;
}

/// Licences of everything Charon ships with, from the Trust board.
class LicencesScreen extends StatefulWidget {
  const LicencesScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<LicencesScreen> createState() => _LicencesScreenState();
}

class _LicencesScreenState extends State<LicencesScreen> {
  /// The Charon row starts open, as on the board.
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _Lic('Charon', 'GPL 3.0', l10n.trustLicSubApp, _gplText, l10n.trustLinkSource),
      _Lic('Xray core', 'MPL 2.0', l10n.trustLicSubXray, _mplText, l10n.trustLinkBundled),
      _Lic('wintun', null, l10n.trustLicSubWintun, l10n.trustLicTextWintun, l10n.trustLinkProject),
      _Lic('Go modules', l10n.trustChipMixed, l10n.trustLicSubGo, l10n.trustLicTextGo, l10n.trustLinkModules),
      _Lic('Flutter packages', l10n.trustChipMixed, l10n.trustLicSubFlutter, l10n.trustLicTextFlutter,
          l10n.trustLinkPackages),
      _Lic('Fonts', 'OFL 1.1', l10n.trustLicSubFonts, _oflText, l10n.trustLinkFonts),
    ];

    return TrustPage(
      controller: widget.controller,
      crumb: l10n.trustLicCrumb,
      title: l10n.trustLicTitle,
      meta: l10n.trustLicMeta('v$appVersion'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.trustLicIntro, style: TextStyle(fontSize: 13, height: 1.45, color: colors.text2)),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.trustLicTitle,
            container: true,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final (i, l) in items.indexed)
                    _row(colors, l10n, l, i, open: _open == i),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('> ${l10n.trustLicNote}', style: monoStyle(colors.text3, 10).copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _row(CharonColors colors, AppLocalizations l10n, _Lic l, int i, {required bool open}) {
    final toConfirm = l.chip == null;
    final chip = l.chip ?? l10n.trustChipConfirm;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: i == 0 ? null : Border(top: BorderSide(color: colors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = open ? -1 : i),
            child: Semantics(
              button: true,
              expanded: open,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l.name,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 18,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: toConfirm ? colors.transitionSoft : colors.surface2,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  chip,
                                  style: monoStyle(toConfirm ? colors.transitionText : colors.text2, 9,
                                      bold: true, em: 0.06),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(l.sub, style: monoStyle(colors.text3, 10)),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: open ? -1.5708 : 1.5708,
                      child: Icon(Icons.chevron_right, size: 16, color: colors.text3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.text, style: monoStyle(colors.text, 10).copyWith(height: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TrustLink(l10n.trustLicFullText),
                      const SizedBox(width: 16),
                      TrustLink(l.link),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
