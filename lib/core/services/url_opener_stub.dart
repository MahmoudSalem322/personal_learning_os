import 'url_opener.dart';

/// Non-web platforms (unit and widget tests): nothing to open.
UrlOpener createUrlOpener() => const _NoopUrlOpener();

class _NoopUrlOpener implements UrlOpener {
  const _NoopUrlOpener();

  @override
  bool openInNewTab(String url) => false;
}
