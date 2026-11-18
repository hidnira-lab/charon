import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../sync/vault_codec.dart';

/// The two system dialogs the file backup needs. A class so a test can hand the
/// Sync card a fake instead of opening a real window.
class VaultFilePicker {
  const VaultFilePicker();

  static const _group = XTypeGroup(label: 'Charon vault', extensions: ['charonvault']);

  /// Save dialog for a backup. Null when the user cancels.
  Future<File?> chooseBackupTarget(DateTime now) async {
    final day = now.toIso8601String().substring(0, 10);
    final place = await getSaveLocation(
      acceptedTypeGroups: const [_group],
      suggestedName: 'charon-$day${FileVaultAdapter.fileExtension}',
    );
    return place == null ? null : File(place.path);
  }

  /// Open dialog for a restore. Null when the user cancels.
  Future<File?> chooseRestoreSource() async {
    final file = await openFile(acceptedTypeGroups: const [_group]);
    return file == null ? null : File(file.path);
  }
}
