import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'url_opener_stub.dart'
    if (dart.library.js_interop) 'url_opener_web.dart'
    if (dart.library.io) 'url_opener_io.dart'
    as platform;

/// Opens external links. Abstracted so widgets and tests don't depend on
/// browser APIs.
abstract interface class UrlOpener {
  /// Opens [url] in a new browser tab. Returns `false` if the browser
  /// refused (e.g. a pop-up blocker).
  ///
  /// Must be called directly from a user gesture (before any `await`),
  /// otherwise browsers treat it as an unsolicited pop-up.
  bool openInNewTab(String url);
}

final urlOpenerProvider = Provider<UrlOpener>(
  (ref) => platform.createUrlOpener(),
);
