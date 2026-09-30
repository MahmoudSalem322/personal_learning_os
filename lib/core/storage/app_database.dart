import 'package:sembast/sembast.dart';

/// Document stores of the local database.
///
/// Every persisted collection is declared here, so the full set of stores is
/// known in one place (for migrations, backup and "clear data").
abstract final class AppStores {
  /// Single-record store holding the user's app preferences.
  static final StoreRef<String, Map<String, Object?>> settings =
      stringMapStoreFactory.store('settings');

  /// Learning areas, keyed by category id.
  static final StoreRef<String, Map<String, Object?>> categories =
      stringMapStoreFactory.store('categories');

  /// Learning resources, keyed by resource id.
  static final StoreRef<String, Map<String, Object?>> resources =
      stringMapStoreFactory.store('resources');

  /// Markdown notes, keyed by note id.
  static final StoreRef<String, Map<String, Object?>> notes =
      stringMapStoreFactory.store('notes');

  /// Learning tasks, keyed by task id.
  static final StoreRef<String, Map<String, Object?>> tasks =
      stringMapStoreFactory.store('tasks');

  static List<StoreRef<String, Map<String, Object?>>> get all => [
    settings,
    categories,
    resources,
    notes,
    tasks,
  ];
}

/// Opens the local database and runs schema migrations.
abstract final class AppDatabase {
  static const String name = 'personal_learning_os.db';

  /// Bump this and add a step in [_migrate] whenever stored data needs to be
  /// reshaped. Never edit a migration that has already shipped.
  static const int schemaVersion = 1;

  static Future<Database> open(DatabaseFactory factory) {
    return factory.openDatabase(
      name,
      version: schemaVersion,
      onVersionChanged: _migrate,
    );
  }

  static Future<void> _migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 1 is the initial schema: stores are created lazily on first
    // write, so there is nothing to do yet. Future steps look like:
    //
    // if (oldVersion < 2) { ... }
  }
}
