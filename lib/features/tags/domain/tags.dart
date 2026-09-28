/// Rules for the tags shared by resources (and later notes and tasks).
///
/// Tags are stored normalized: lowercase, without `#`, words joined with
/// `-`. Letters from any script are allowed, so Arabic tags work too.
abstract final class TagRules {
  static const int maxLength = 30;
  static const int maxPerItem = 10;

  static final RegExp _invalid = RegExp(r'[^\p{L}\p{N}\-_]', unicode: true);

  /// "#State Management " → "state-management". Returns an empty string
  /// when nothing usable is left.
  static String normalize(String raw) {
    var tag = raw.trim().toLowerCase();
    while (tag.startsWith('#')) {
      tag = tag.substring(1);
    }
    tag = tag
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(_invalid, '')
        .replaceAll(RegExp('-{2,}'), '-');
    tag = tag.replaceAll(RegExp(r'^-+|-+$'), '');
    return tag.length > maxLength ? tag.substring(0, maxLength) : tag;
  }

  /// Normalizes, drops empties and removes duplicates, keeping order.
  static List<String> normalizeAll(Iterable<String> raw) {
    final seen = <String>{};
    return [
      for (final tag in raw.map(normalize))
        if (tag.isNotEmpty && seen.add(tag)) tag,
    ];
  }

  /// Splits free text like "flutter, #dart ui" into tags.
  static List<String> parse(String input) =>
      normalizeAll(input.split(RegExp(r'[,\s]+')));
}
