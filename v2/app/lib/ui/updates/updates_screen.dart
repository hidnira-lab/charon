import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../state/updates_view.dart';
import '../../theme/theme.dart';
import '../common/glass_card.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/file_update_card.dart';
import 'widgets/offline_banner.dart';
import 'widgets/update_card.dart';
import 'widgets/update_rules_card.dart';
import '../common/motion.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _fileCardKey = GlobalKey();

  void _scrollToFileCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _fileCardKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
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

  void _copyCoreLog() {
    Clipboard.setData(ClipboardData(text: widget.controller.coreLogs.map((l) => l.text).join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.updLogCopied),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Turns a button of the board into a call. The ones with no command or no
  /// package behind them are disabled in [UpdateButton], so they never arrive.
  void _act(UpdateAction action) {
    final c = widget.controller;
    switch (action) {
      case UpdateAction.applyNow:
        c.applyCoreUpdate(when: ApplyWhen.APPLY_NOW);
      case UpdateAction.applyWhenDisconnected:
        c.applyCoreUpdate(when: ApplyWhen.APPLY_WHEN_DISCONNECTED);
      case UpdateAction.rollback:
        c.rollbackCore();
      case UpdateAction.check:
        c.checkUpdates();
      case UpdateAction.copyLog:
        _copyCoreLog();
      case UpdateAction.editServers:
        c.setTab(1);
      case UpdateAction.installApp:
        c.applyAppUpdate();
      case UpdateAction.download ||
            UpdateAction.releaseNotes ||
            UpdateAction.allReleases ||
            UpdateAction.cancel ||
            UpdateAction.chooseFile:
        break;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final colors = CharonColors.of(context);
        final l10n = AppLocalizations.of(context)!;
        final view = UpdatesView(l10n, widget.controller, isWindows: Platform.isWindows);
        final checkedLine = view.checkedLine;

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
                    // Each block rises on arrival, 40 ms apart (mPg).
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
                                onTap: _handleBack,
                                child: Text(
                                  '> ${l10n.updatesTag}',
                                  style: monoStyle(colors.text3, 10, bold: true, em: 0.08),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.updatesTitle,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.33,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (checkedLine != null) ...[
                                Throb(child: Text(checkedLine, style: monoStyle(colors.text3, 11))),
                                const SizedBox(width: 12),
                              ],
                              Opacity(
                                opacity: widget.controller.isCheckingUpdates ? 0.4 : 1,
                                child: InkWell(
                                  onTap: widget.controller.isCheckingUpdates ? null : () => _act(UpdateAction.check),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: colors.controlBorder),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(l10n.updCheckNow, style: monoStyle(colors.text, 12, bold: true)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!view.online) ...[
                                Enter.page(index: 1, child: OfflineBanner(onScrollToFileUpdate: _scrollToFileCard)),
                                const SizedBox(height: 14),
                              ],
                              Enter.page(
                                index: view.online ? 1 : 2,
                                child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: UpdateCard(view: view.core, onAction: _act)),
                                    const SizedBox(width: 16),
                                    Expanded(child: UpdateCard(view: view.app, onAction: _act)),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 14),
                              KeyedSubtree(
                                key: _fileCardKey,
                                child: Enter.page(index: view.online ? 2 : 3, child: FileUpdateCard(view: view.file, onAction: _act)),
                              ),
                              const SizedBox(height: 14),
                              Enter.page(
                                index: view.online ? 3 : 4,
                                child: UpdateRulesCard(controller: widget.controller),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
