/// Helpers for user-entered web addresses.
abstract final class UrlUtils {
  static const int maxLength = 2048;

  /// Turns user input into an absolute http(s) URL, or returns `null` when
  /// it can't be one. A missing scheme defaults to https, so "flutter.dev"
  /// becomes "https://flutter.dev". Empty input returns an empty string.
  static String? normalize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.length > maxLength || trimmed.contains(RegExp(r'\s'))) {
      return null;
    }
    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    final uri = Uri.tryParse(hasScheme ? trimmed : 'https://$trimmed');
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    final host = uri.host;
    final validHost =
        host == 'localhost' ||
        (host.contains('.') && !host.startsWith('.') && !host.endsWith('.'));
    if (!validHost) return null;
    return uri.toString();
  }

  /// Short, readable host for display: "https://www.youtube.com/x" →
  /// "youtube.com". Returns an empty string for unparsable input.
  static String displayHost(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}
