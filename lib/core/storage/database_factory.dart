// Picks the persistent database factory for the current platform.
//
// - Web: sembast on IndexedDB.
// - Android and other native platforms: sembast on a file in the app's
//   documents folder.
// - Anything else: in memory. (Unit and widget tests run on the Dart VM and
//   pass their own in-memory factory to `bootstrap`.)
export 'database_factory_memory.dart'
    if (dart.library.js_interop) 'database_factory_web.dart'
    if (dart.library.io) 'database_factory_io.dart';
