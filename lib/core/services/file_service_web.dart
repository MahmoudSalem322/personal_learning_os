import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'file_service.dart';

FileService createFileService() => const _WebFileService();

class _WebFileService implements FileService {
  const _WebFileService();

  @override
  Future<void> saveText(
    String fileName,
    String content, {
    String mimeType = 'application/json',
  }) async {
    final blob = web.Blob(
      [content.toJS].toJS,
      web.BlobPropertyBag(type: '$mimeType;charset=utf-8'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    // Give the browser a moment to start the download before revoking.
    Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
  }

  @override
  Future<PickedTextFile?> pickText({
    String accept = '.json,application/json',
    int maxBytes = 20 * 1024 * 1024,
  }) {
    final completer = Completer<web.File?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept
      ..style.display = 'none';

    void finish(web.File? file) {
      if (!completer.isCompleted) completer.complete(file);
      input.remove();
    }

    input
      ..addEventListener(
        'change',
        ((web.Event _) {
          final files = input.files;
          finish(files != null && files.length > 0 ? files.item(0) : null);
        }).toJS,
      )
      // Fired when the user closes the dialog without choosing a file.
      ..addEventListener('cancel', ((web.Event _) => finish(null)).toJS);
    web.document.body!.append(input);
    input.click();

    return completer.future.then((file) async {
      if (file == null) return null;
      if (file.size > maxBytes) throw FileTooLargeException(file.size);
      final text = await file.text().toDart;
      return PickedTextFile(name: file.name, content: text.toDart);
    });
  }
}
