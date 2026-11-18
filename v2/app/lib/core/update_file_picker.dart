import 'dart:io';

import 'package:file_selector/file_selector.dart';

/// The open dialog of "Update from a file". A class so a test can hand the
/// Updates screen a fake instead of opening a real window.
class UpdateFilePicker {
  const UpdateFilePicker();

  /// Null when the user cancels.
  Future<File?> chooseBundle() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Charon update', extensions: ['charonup']),
      ],
    );
    return file == null ? null : File(file.path);
  }
}
