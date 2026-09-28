import 'package:sembast/sembast_memory.dart';

/// In-memory factory used on platforms without a persistent implementation.
DatabaseFactory get platformDatabaseFactory => databaseFactoryMemory;

/// Whether [platformDatabaseFactory] keeps data across sessions.
const bool platformStorageIsPersistent = false;
