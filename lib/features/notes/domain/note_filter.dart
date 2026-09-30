import 'package:flutter/foundation.dart' show immutable;

import 'note.dart';

enum NoteSort { recentlyUpdated, recentlyCreated, title }

/// What the notes list shows. Pure data; [apply] does the work.
@immutable
class NoteFilter {
  const NoteFilter({
    this.query = '',
    this.categoryId,
    this.tag,
    this.favoritesOnly = false,
    this.sort = NoteSort.recentlyUpdated,
  });

  /// [categoryId] value that matches notes without a category.
  static const String uncategorized = '__uncategorized__';

  final String query;
  final String? categoryId;
  final String? tag;
  final bool favoritesOnly;
  final NoteSort sort;

  bool get hasFilters => categoryId != null || tag != null || favoritesOnly;

  static const Object _unset = Object();

  /// Pass `null` for [categoryId] or [tag] to clear that filter.
  NoteFilter copyWith({
    String? query,
    Object? categoryId = _unset,
    Object? tag = _unset,
    bool? favoritesOnly,
    NoteSort? sort,
  }) {
    return NoteFilter(
      query: query ?? this.query,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      tag: identical(tag, _unset) ? this.tag : tag as String?,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }

  /// Keeps the search text and sort, clears everything else.
  NoteFilter cleared() => NoteFilter(query: query, sort: sort);

  bool matches(Note n) {
    if (categoryId == uncategorized) {
      if (n.categoryId != null) return false;
    } else if (categoryId != null && n.categoryId != categoryId) {
      return false;
    }
    if (tag != null && !n.tags.contains(tag)) return false;
    if (favoritesOnly && !n.isFavorite) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final term = q.startsWith('#') ? q.substring(1) : q;
    return n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q) ||
        n.tags.any((t) => t.contains(term));
  }

  List<Note> apply(List<Note> notes) {
    final result = notes.where(matches).toList();
    result.sort(_comparator);
    return result;
  }

  int _comparator(Note a, Note b) => switch (sort) {
    NoteSort.recentlyUpdated => b.updatedAt.compareTo(a.updatedAt),
    NoteSort.recentlyCreated => b.createdAt.compareTo(a.createdAt),
    NoteSort.title => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  };

  @override
  bool operator ==(Object other) =>
      other is NoteFilter &&
      other.query == query &&
      other.categoryId == categoryId &&
      other.tag == tag &&
      other.favoritesOnly == favoritesOnly &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(query, categoryId, tag, favoritesOnly, sort);
}
