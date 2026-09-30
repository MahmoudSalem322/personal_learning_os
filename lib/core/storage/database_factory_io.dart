import 'dart:io' show Platform;

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

/// File-backed factory (Android and other native platforms): data lives in
/// the app's private documents folder and survives restarts and updates.
DatabaseFactory get platformDatabaseFactory => databaseFactoryIo;

/// Whether [platformDatabaseFactory] keeps data across sessions.
const bool platformStorageIsPersistent = true;

/// Absolute path of the database file [name].
Future<String> platformDatabasePath(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}${Platform.pathSeparator}$name';
}
