// Picks the persistent database factory for the current platform.
//
// On the web, sembast is backed by IndexedDB. Everywhere else (unit and
// widget tests on the Dart VM) an in-memory factory is used, because the web
// implementation cannot be compiled outside the browser.
export 'database_factory_memory.dart'
    if (dart.library.js_interop) 'database_factory_web.dart';
