import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Platform side of backups: hand a file to the share sheet (Drive, e-mail,
/// messaging apps, "save to files") and pick a file to restore. Behind an
/// interface so widget tests can replace it.
abstract interface class BackupFiles {
  Future<void> share({
    required String fileName,
    required String content,
    required String subject,
  });

  /// Text content of the picked file; `null` when the user cancelled.
  /// Throws [FormatException] when the file is not UTF-8 text.
  Future<String?> pick();
}

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const PlatformBackupFiles(),
);

class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(utf8.encode(content), mimeType: 'application/json'),
        ],
        fileNameOverrides: [fileName],
        subject: subject,
      ),
    );
  }

  @override
  Future<String?> pick() async {
    // Any type: some file managers report JSON as a generic binary file.
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes());
  }
}
