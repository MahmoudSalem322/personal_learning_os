/// Base type for expected, recoverable failures.
///
/// Repositories and services translate low-level errors (storage, parsing,
/// invalid input, ...) into an [AppException] so the presentation layer can
/// react without knowing which technology failed. Features define their own
/// subtypes (e.g. validation errors) next to their domain models.
abstract class AppException implements Exception {
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

/// The requested record does not exist (e.g. it was deleted meanwhile).
final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
