import 'package:sembast_web/sembast_web.dart';

/// IndexedDB-backed factory: data survives refreshes, closing the browser
/// and restarting the device.
DatabaseFactory get platformDatabaseFactory => databaseFactoryWeb;

/// Whether [platformDatabaseFactory] keeps data across sessions.
const bool platformStorageIsPersistent = true;

/// Where [platformDatabaseFactory] opens the database called [name].
Future<String> platformDatabasePath(String name) async => name;
