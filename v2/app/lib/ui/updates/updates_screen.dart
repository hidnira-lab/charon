import 'package:flutter/material.dart';

import '../../gen/charon/v1/charon.pb.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/home_controller.dart';
import '../../theme/theme.dart';
import '../home/widgets/rail_nav.dart';
import 'widgets/app_update_card.dart';
import 'widgets/core_update_card.dart';
import 'widgets/file_update_card.dart';
import 'widgets/offline_banner.dart';

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

  void _scrollToBottomFileCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_fileCardKey.currentContext != null) {
        Scrollable.ensureVisible(
          _fileCardKey.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
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
        final isConnected = widget.controller.status.phase == Phase.PHASE_UP ||
            widget.controller.status.phase == Phase.PHASE_VERIFYING;

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
                                '> ${l10n.updatesTag}',
                                style: CharonTypography.label.copyWith(
                                  color: colors.text3,
                                  letterSpacing: 1.2,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: CharonSpacing.s1),
                              Text(
                                l10n.updatesTitle,
                                style: CharonTypography.h1.copyWith(fontSize: 22.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: CharonSpacing.s4),

                      // Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Amber banner if disconnected
                              if (!isConnected) ...[
                                OfflineBanner(
                                  onConnect: widget.controller.connect,
                                  onScrollToFileUpdate: _scrollToBottomFileCard,
                                ),
                                const SizedBox(height: CharonSpacing.s4),
                              ],

                              // 1. Xray Core Update Card
                              CoreUpdateCard(
                                updateState: widget.controller.coreUpdateState,
                                onApplyNow: () => widget.controller.applyCoreUpdate(
                                  when: ApplyWhen.APPLY_NOW,
                                ),
                                onApplyWhenDisconnect: () => widget.controller.applyCoreUpdate(
                                  when: ApplyWhen.APPLY_WHEN_DISCONNECTED,
                                ),
                                onCheckUpdates: widget.controller.checkUpdates,
                                onRollback: widget.controller.rollbackCore,
                              ),
                              const SizedBox(height: CharonSpacing.s4),

                              // 2. Charon App Update Card
                              AppUpdateCard(
                                updateState: widget.controller.appUpdateState,
                                onRestartUpdate: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Restarting Charon and applying update...'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                onOpenReleasePage: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening GitHub release page...'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: CharonSpacing.s4),

                              // 3. Update from a file Card
                              Container(
                                key: _fileCardKey,
                                child: FileUpdateCard(
                                  isUploading: widget.controller.isFileUploading,
                                  progress: widget.controller.fileUploadProgress,
                                  verificationResult: widget.controller.fileVerificationResult,
                                  onChooseFile: () => widget.controller.simulateFileUpload(
                                    outcome: 'verified',
                                  ),
                                  onApplyFileUpdate: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('File update applied successfully.'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    widget.controller.resetFileUpload();
                                  },
                                  onReset: widget.controller.resetFileUpload,
                                ),
                              ),
                              const SizedBox(height: CharonSpacing.s5),
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
