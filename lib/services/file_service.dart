import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/attached_file.dart';

class FileService {
  static const allowedExtensions = ['txt', 'pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];

  Future<AttachedFile?> pickAndPersistFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final selected = result.files.single;
    if (selected.path == null) {
      return null;
    }

    final source = File(selected.path!);
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');
    if (!attachmentsDir.existsSync()) {
      await attachmentsDir.create(recursive: true);
    }

    final fileName = selected.name;
    final targetPath = '${attachmentsDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final copied = await source.copy(targetPath);

    final extension = fileName.split('.').last.toLowerCase();
    return AttachedFile(
      path: copied.path,
      name: fileName,
      extension: extension,
      addedAt: DateTime.now(),
    );
  }

  Future<String> exportNoteAsTxt({required String title, required String content}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${appDir.path}/exports');
    if (!exportsDir.existsSync()) {
      await exportsDir.create(recursive: true);
    }

    final sanitizedTitle = title.trim().isEmpty
        ? 'untitled_note'
        : title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final path = '${exportsDir.path}/${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(path);
    await file.writeAsString(content);
    return path;
  }
}
