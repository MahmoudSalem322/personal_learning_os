import 'backup_snapshot.dart';

/// Reads and replaces all of the user's data at once.
///
/// Implementations throw `StorageException` on failure.
abstract interface class BackupStore {
  /// Everything currently stored. Unreadable records are skipped.
  Future<BackupSnapshot> read();

  /// Replaces all stored data (settings included) with [snapshot] in a
  /// single transaction: either everything is written or nothing changes.
  Future<void> replaceAll(BackupSnapshot snapshot);
}
