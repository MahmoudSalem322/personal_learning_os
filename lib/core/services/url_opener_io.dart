import 'package:url_launcher/url_launcher.dart';

import 'url_opener.dart';

UrlOpener createUrlOpener() => const _NativeUrlOpener();

/// Android and other native platforms: opens links in the default browser
/// (or the app registered for them, e.g. YouTube).
class _NativeUrlOpener implements UrlOpener {
  const _NativeUrlOpener();

  @override
  bool openInNewTab(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    // Launching is asynchronous; there's no pop-up blocker to report on.
    launchUrl(uri, mode: LaunchMode.externalApplication).ignore();
    return true;
  }
}
