import 'package:web/web.dart' as web;

import 'url_opener.dart';

UrlOpener createUrlOpener() => const _WebUrlOpener();

class _WebUrlOpener implements UrlOpener {
  const _WebUrlOpener();

  @override
  bool openInNewTab(String url) {
    // noopener: the opened page can't navigate this tab via window.opener.
    // With noopener, window.open returns null even on success, so a thrown
    // error is the only reliable failure signal here.
    try {
      web.window.open(url, '_blank', 'noopener,noreferrer');
      return true;
    } catch (_) {
      return false;
    }
  }
}
