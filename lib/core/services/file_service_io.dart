import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import 'file_service.dart';

FileService createFileService() => const _NativeFileService();

/// Android and other native platforms: the system "save to" and "open"
/// dialogs, so backups can go to Downloads, Drive, etc.
class _NativeFileService implements FileService {
  const _NativeFileService();

  @override
  Future<void> saveText(
    String fileName,
    String content, {
    String mimeType = 'application/json',
  }) async {
    await FilePicker.saveFile(
      fileName: fileName,
      bytes: utf8.encode(content),
      mimeType: mimeType,
    );
  }

  @override
  Future<PickedTextFile?> pickText({
    String accept = '.json,application/json',
    int maxBytes = 20 * 1024 * 1024,
  }) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final size = await file.xFile.length();
    if (size > maxBytes) throw FileTooLargeException(size);
    return PickedTextFile(
      name: file.name,
      content: await file.xFile.readAsString(),
    );
  }
}
