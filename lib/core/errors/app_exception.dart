/// Base type for expected, recoverable failures.
///
/// Repositories translate low-level errors (storage, parsing, ...) into an
/// [AppException] so the presentation layer can react without knowing which
/// technology failed. More subtypes are added as features need them.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// Developer-facing description. Never shown to the user as-is; the UI
  /// maps exception types to localized messages.
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '$runtimeType: $message${cause == null ? '' : ' ($cause)'}';
}

/// Reading from or writing to local storage failed.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause, super.stackTrace});
}
