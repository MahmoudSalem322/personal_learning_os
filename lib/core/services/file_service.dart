import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_service_stub.dart'
    if (dart.library.js_interop) 'file_service_web.dart'
    if (dart.library.io) 'file_service_io.dart'
    as platform;

/// A text file the user picked.
@immutable
class PickedTextFile {
  const PickedTextFile({required this.name, required this.content});

  final String name;
  final String content;
}

/// Saving and opening files. Abstracted so features and tests don't depend
/// on browser APIs.
abstract interface class FileService {
  /// Offers [content] as a download named [fileName].
  Future<void> saveText(
    String fileName,
    String content, {
    String mimeType = 'application/json',
  });

  /// Lets the user pick a text file. `null` when they cancel. Files larger
  /// than [maxBytes] throw [FileTooLargeException] without being read.
  Future<PickedTextFile?> pickText({
    String accept = '.json,application/json',
    int maxBytes = 20 * 1024 * 1024,
  });
}

/// The picked file is over the size limit.
class FileTooLargeException implements Exception {
  const FileTooLargeException(this.bytes);

  final int bytes;

  @override
  String toString() => 'FileTooLargeException($bytes bytes)';
}

final fileServiceProvider = Provider<FileService>(
  (ref) => platform.createFileService(),
);
