import 'dart:async';
import 'dart:developer' as developer;

import '../errors/app_exception.dart';

/// Runs a storage operation and turns any failure into [StorageException].
Future<T> guardStorage<T>(String action, Future<T> Function() body) async {
  try {
    return await body();
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    throw StorageException(
      'Failed to $action',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}

/// Stream counterpart of [guardStorage].
StreamTransformer<T, T> storageErrors<T>(String action) =>
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) => sink.addError(
        error is AppException
            ? error
            : StorageException(
                'Failed to $action',
                cause: error,
                stackTrace: stackTrace,
              ),
        stackTrace,
      ),
    );

/// Parses a stored record, or logs and returns `null` if it's unreadable,
/// so one corrupted record never breaks a whole list.
T? tryParseRecord<T>(
  String kind,
  Map<String, Object?> json,
  T Function(Map<String, Object?>) parse,
) {
  try {
    return parse(json);
  } on FormatException catch (error) {
    developer.log('Skipping unreadable $kind', name: 'storage', error: error);
    return null;
  }
}
