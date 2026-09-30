import 'dart:developer' as developer;

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:sembast/sembast_memory.dart';

import '../core/storage/app_database.dart';
import '../core/storage/database_factory.dart';
import '../core/storage/storage_providers.dart';
import '../features/settings/data/local_settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/settings_controller.dart';

/// Prepares everything the first frame needs: opens the local database and
/// reads the user's settings.
///
/// Never throws. If persistent storage can't be opened (e.g. IndexedDB is
/// blocked) the app still starts on an in-memory database and shows a
/// warning; if stored settings are unreadable, defaults are used.
Future<List<Override>> bootstrap({
  DatabaseFactory? databaseFactory,
  bool isPersistent = platformStorageIsPersistent,
}) async {
  final factory = databaseFactory ?? platformDatabaseFactory;

  Database database;
  var status = isPersistent ? StorageStatus.persistent : StorageStatus.volatile;
  try {
    database = await AppDatabase.open(
      factory,
      // Tests pass their own factory; only the platform one needs a path.
      path: databaseFactory == null
          ? await platformDatabasePath(AppDatabase.name)
          : AppDatabase.name,
    );
  } catch (error, stackTrace) {
    developer.log(
      'Persistent storage unavailable, using in-memory database',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
    database = await AppDatabase.open(newDatabaseFactoryMemory());
    status = StorageStatus.volatile;
  }

  AppSettings settings;
  try {
    settings = await LocalSettingsRepository(database).load();
  } catch (error, stackTrace) {
    developer.log(
      'Could not read settings, using defaults',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
    settings = AppSettings.defaults;
  }

  return [
    appDatabaseProvider.overrideWithValue(database),
    storageStatusProvider.overrideWithValue(status),
    initialSettingsProvider.overrideWithValue(settings),
  ];
}
