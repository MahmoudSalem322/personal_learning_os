import 'file_service.dart';

/// Non-web platforms (unit and widget tests): no file system access.
FileService createFileService() => const _UnsupportedFileService();

class _UnsupportedFileService implements FileService {
  const _UnsupportedFileService();

  @override
  Future<void> saveText(
    String fileName,
    String content, {
    String mimeType = 'application/json',
  }) => Future.error(UnsupportedError('Saving files needs a browser'));

  @override
  Future<PickedTextFile?> pickText({
    String accept = '.json,application/json',
    int maxBytes = 20 * 1024 * 1024,
  }) => Future.error(UnsupportedError('Picking files needs a browser'));
}
