import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

/// Whether data written in this session survives a reload.
enum StorageStatus {
  /// Backed by IndexedDB.
  persistent,

  /// Browser storage was unavailable (for example, blocked in a private
  /// window), so the app runs on an in-memory database.
  volatile,
}

/// The opened local database. Provided by `bootstrap()` before the first
/// frame; repositories depend on it, widgets never do.
final appDatabaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final storageStatusProvider = Provider<StorageStatus>(
  (ref) => throw UnimplementedError('storageStatusProvider must be overridden'),
);
