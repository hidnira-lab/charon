import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';

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
  final Set<String> _expandedKeys = {};

  void _toggleExpanded(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) {
        _expandedKeys.remove(key);
      } else {
        _expandedKeys.add(key);
      }
    });
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      widget.controller.setTab(4); // Back to Settings tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CharonColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final licenceItems = [
      _LicenceData(
        key: 'charon',
        title: l10n.licencesCharonTitle,
        type: l10n.licencesCharonType,
        sourceUrl: 'https://github.com/hidnira-lab/charon',
        summary:
            'Charon client, background service, and IPC protocol implementation are licensed under the GNU General Public License v3.0.',
        fullText: '''GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2026 Dayat (@hidnira)
Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.''',
      ),
      _LicenceData(
        key: 'xray',
        title: l10n.licencesXrayTitle,
        type: l10n.licencesXrayType,
        sourceUrl: 'https://github.com/XTLS/Xray-core',
        summary:
            'Xray core binary engine powering the VLESS Reality proxy tunnel is licensed under the Mozilla Public License 2.0.',
        fullText: '''Mozilla Public License Version 2.0
==================================

1. Definitions
1.1. "Contributor" means each individual or entity that creates, contributes
to the creation of, or owns Covered Software.
...
2. Grant of Rights
2.1. Major Grants: Each Contributor hereby grants You a world-wide,
royalty-free, non-exclusive license under its Intellectual Property Rights
to use, reproduce, make available, modify, display, perform, distribute
and otherwise exploit its Contributions.''',
      ),
      _LicenceData(
        key: 'wintun',
        title: l10n.licencesWintunTitle,
        type: l10n.licencesWintunType,
        sourceUrl: 'https://www.wintun.net',
        summary:
            'High-performance TUN driver for Windows networking layer, licensed under the GNU General Public License v2.0.',
        fullText: '''GNU GENERAL PUBLIC LICENSE Version 2, June 1991
Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.''',
      ),
      _LicenceData(
        key: 'go',
        title: l10n.licencesGoModulesTitle,
        type: l10n.licencesGoModulesType,
        sourceUrl: 'https://golang.org',
        summary:
            'google.golang.org/protobuf (BSD-3 Clause), github.com/microsoft/go-winio (MIT), and golang.org/x/sys (BSD-3 Clause).',
        fullText: '''Copyright (c) 2009 The Go Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.''',
      ),
      _LicenceData(
        key: 'dart',
        title: l10n.licencesDartPackagesTitle,
        type: l10n.licencesDartPackagesType,
        sourceUrl: 'https://pub.dev',
        summary:
            'Flutter SDK (BSD-3), dart_ipc (MIT), win32 (BSD-3), protobuf (BSD-3), fixnum (BSD-3), and intl (BSD-3).',
        fullText: '''Copyright 2014 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the conditions are met.''',
      ),
      _LicenceData(
        key: 'fonts',
        title: l10n.licencesFontsTitle,
        type: l10n.licencesFontsType,
        sourceUrl: 'https://scripts.sil.org/OFL',
        summary:
            'Inter (Rasmus Andersson) and Space Mono (Colophon Foundry) are licensed under the SIL Open Font License 1.1.',
        fullText: '''SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide development
of collaborative font projects, to support the font creation efforts of academic
and linguistic communities, and to provide a free and open framework in which
fonts may be shared and improved in partnership with others.''',
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          RailNav(
            controller: widget.controller,
            selectedIndex: 4,
            onTabSelected: widget.controller.setTab,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _handleBack,
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                l10n.updatesBackToSettings,
                                style: CharonTypography.caption.copyWith(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            '> ${l10n.licencesTag}',
                            style: CharonTypography.label.copyWith(
                              color: colors.text3,
                              letterSpacing: 1.2,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            l10n.licencesTitle,
                            style: CharonTypography.h1.copyWith(fontSize: 22.0),
                          ),
                          const SizedBox(height: CharonSpacing.s1),
                          Text(
                            l10n.licencesSubtitle,
                            style: CharonTypography.body.copyWith(
                              color: colors.text2,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: CharonSpacing.s4),

                  // Licences List
                  Expanded(
                    child: ListView.separated(
                      itemCount: licenceItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: CharonSpacing.s3),
                      itemBuilder: (context, index) {
                        final item = licenceItems[index];
                        final isExpanded = _expandedKeys.contains(item.key);

                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: colors.divider, width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: CharonTypography.label.copyWith(
                                            color: colors.text,
                                            fontSize: 13.0,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          item.type,
                                          style: CharonTypography.code.copyWith(
                                            color: colors.accent,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Expand toggle button
                                  OutlinedButton(
                                    onPressed: () => _toggleExpanded(item.key),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colors.text,
                                      side: BorderSide(color: colors.controlBorder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      minimumSize: const Size(0, 28.0),
                                    ),
                                    child: Text(
                                      isExpanded
                                          ? l10n.licencesHideFullText
                                          : l10n.licencesViewFullText,
                                      style: CharonTypography.caption.copyWith(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: CharonSpacing.s2),
                              Text(
                                item.summary,
                                style: CharonTypography.body.copyWith(
                                  color: colors.text2,
                                  fontSize: 12.0,
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: CharonSpacing.s3),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: colors.surface2,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: colors.controlBorder),
                                  ),
                                  child: Text(
                                    item.fullText,
                                    style: CharonTypography.code.copyWith(
                                      color: colors.text3,
                                      fontSize: 10.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenceData {
  const _LicenceData({
    required this.key,
    required this.title,
    required this.type,
    required this.sourceUrl,
    required this.summary,
    required this.fullText,
  });

  final String key;
  final String title;
  final String type;
  final String sourceUrl;
  final String summary;
  final String fullText;
}
