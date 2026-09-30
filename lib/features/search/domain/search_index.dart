import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../resources/domain/resource.dart';
import '../../tags/domain/tags.dart';
import '../../tasks/domain/task.dart';
import 'search_hit.dart';

/// Searchable copy of the user's data with text lowercased once, so each
/// keystroke only scans strings.
///
/// Ranking: exact title → title prefix → a title word starts with the query
/// → title contains it → every query word in the title → found elsewhere
/// (description, content, URL, tags). Ties go to the most recently updated.
/// A query starting with `#` searches tags only.
class SearchIndex {
  SearchIndex({
    required List<Category> categories,
    required List<Resource> resources,
    required List<Note> notes,
    required List<Task> tasks,
  }) : _categories = [
         for (final c in categories)
           _Entry(c, c.name, [c.description], const [], c.updatedAt),
       ],
       _resources = [
         for (final r in resources)
           _Entry(r, r.title, [r.description, r.url], r.tags, r.updatedAt),
       ],
       _notes = [
         for (final n in notes)
           if (!n.isBlank) _Entry(n, n.title, [n.content], n.tags, n.updatedAt),
       ],
       _tasks = [
         for (final t in tasks)
           _Entry(t, t.title, [t.description], t.tags, t.updatedAt),
       ],
       _tagCounts = _countTags([
         for (final r in resources) r.tags,
         for (final n in notes)
           if (!n.isBlank) n.tags,
         for (final t in tasks) t.tags,
       ]);

  static final SearchIndex empty = SearchIndex(
    categories: const [],
    resources: const [],
    notes: const [],
    tasks: const [],
  );

  final List<_Entry<Category>> _categories;
  final List<_Entry<Resource>> _resources;
  final List<_Entry<Note>> _notes;
  final List<_Entry<Task>> _tasks;
  final Map<String, int> _tagCounts;

  /// Groups of at most [limitPerKind] hits each, best first.
  SearchResults search(String query, {int limitPerKind = 5}) {
    final raw = query.trim().toLowerCase();
    if (raw.isEmpty) return SearchResults.empty;

    final matcher = raw.startsWith('#')
        ? _Matcher.tag(TagRules.normalize(raw))
        : _Matcher.text(raw);

    SearchGroup? group<T>(
      SearchKind kind,
      List<_Entry<T>> entries,
      SearchHit Function(T item, int score) hit,
    ) {
      final scored = <(_Entry<T>, int)>[];
      for (final e in entries) {
        final score = matcher.score(e);
        if (score > 0) scored.add((e, score));
      }
      if (scored.isEmpty) return null;
      scored.sort((a, b) {
        final byScore = b.$2.compareTo(a.$2);
        return byScore != 0
            ? byScore
            : b.$1.updatedAt.compareTo(a.$1.updatedAt);
      });
      return SearchGroup(
        kind: kind,
        total: scored.length,
        hits: [
          for (final (e, score) in scored.take(limitPerKind))
            hit(e.item, score),
        ],
      );
    }

    return SearchResults(query, [
      ?group(SearchKind.category, _categories, CategoryHit.new),
      ?group(SearchKind.resource, _resources, ResourceHit.new),
      ?group(SearchKind.note, _notes, NoteHit.new),
      ?group(SearchKind.task, _tasks, TaskHit.new),
      ?_tagGroup(matcher, limitPerKind),
    ]);
  }

  SearchGroup? _tagGroup(_Matcher matcher, int limit) {
    final term = matcher.tagTerm;
    if (term.isEmpty && !matcher.tagsOnly) return null;
    final hits = <TagHit>[];
    for (final MapEntry(key: tag, value: count) in _tagCounts.entries) {
      final score = term.isEmpty
          ? 1
          : tag == term
          ? 100
          : tag.startsWith(term)
          ? 80
          : tag.contains(term)
          ? 40
          : 0;
      if (score > 0) hits.add(TagHit(tag, count, score));
    }
    if (hits.isEmpty) return null;
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.tag.compareTo(b.tag);
    });
    return SearchGroup(
      kind: SearchKind.tag,
      total: hits.length,
      hits: hits.take(limit).toList(),
    );
  }

  static Map<String, int> _countTags(Iterable<List<String>> tagLists) {
    final counts = <String, int>{};
    for (final tags in tagLists) {
      for (final tag in tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }
}

class _Entry<T> {
  _Entry(this.item, String title, List<String> text, this.tags, this.updatedAt)
    : title = title.toLowerCase(),
      text = text.join('\n').toLowerCase();

  final T item;
  final String title;
  final String text;
  final List<String> tags;
  final DateTime updatedAt;
}

/// Scores entries against one query.
class _Matcher {
  _Matcher.text(this.query)
    : words = query.split(RegExp(r'\s+')),
      tagTerm = TagRules.normalize(query),
      tagsOnly = false;

  _Matcher.tag(this.tagTerm)
    : query = tagTerm,
      words = const [],
      tagsOnly = true;

  final String query;
  final List<String> words;

  /// The query as a tag (for tag matches and the tags group).
  final String tagTerm;

  /// `#query`: only tags count.
  final bool tagsOnly;

  int score(_Entry<Object?> e) {
    if (tagsOnly) {
      if (tagTerm.isEmpty) return 0;
      if (e.tags.contains(tagTerm)) return 100;
      return e.tags.any((t) => t.startsWith(tagTerm)) ? 60 : 0;
    }
    final title = e.title;
    if (title == query) return 100;
    if (title.startsWith(query)) return 80;
    if (title.contains(' $query')) return 65;
    if (title.contains(query)) return 50;
    if (words.every(title.contains)) return 40;
    if (tagTerm.isNotEmpty && e.tags.contains(tagTerm)) return 30;
    bool found(String word) =>
        title.contains(word) ||
        e.text.contains(word) ||
        e.tags.any((t) => t.contains(word));
    return words.every(found) ? 10 : 0;
  }
}
