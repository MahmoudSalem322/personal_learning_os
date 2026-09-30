import 'package:flutter/foundation.dart' show immutable;

import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../resources/domain/resource.dart';
import '../../tasks/domain/task.dart';

/// What a search hit points to. Also the order of groups in the results.
enum SearchKind { category, resource, note, task, tag }

/// One search result. [score] ranks hits within a group (higher first).
@immutable
sealed class SearchHit {
  const SearchHit(this.score);

  final int score;

  SearchKind get kind;
}

final class CategoryHit extends SearchHit {
  const CategoryHit(this.category, super.score);

  final Category category;

  @override
  SearchKind get kind => SearchKind.category;
}

final class ResourceHit extends SearchHit {
  const ResourceHit(this.resource, super.score);

  final Resource resource;

  @override
  SearchKind get kind => SearchKind.resource;
}

final class NoteHit extends SearchHit {
  const NoteHit(this.note, super.score);

  final Note note;

  @override
  SearchKind get kind => SearchKind.note;
}

final class TaskHit extends SearchHit {
  const TaskHit(this.task, super.score);

  final Task task;

  @override
  SearchKind get kind => SearchKind.task;
}

/// A tag in use; [count] is how many items carry it.
final class TagHit extends SearchHit {
  const TagHit(this.tag, this.count, super.score);

  final String tag;
  final int count;

  @override
  SearchKind get kind => SearchKind.tag;
}

/// The hits of one kind: the best [hits] (limited) out of [total].
@immutable
class SearchGroup {
  const SearchGroup({
    required this.kind,
    required this.hits,
    required this.total,
  });

  final SearchKind kind;
  final List<SearchHit> hits;
  final int total;

  bool get hasMore => total > hits.length;
}

/// Grouped results of one query.
@immutable
class SearchResults {
  const SearchResults(this.query, this.groups);

  static const SearchResults empty = SearchResults('', []);

  final String query;

  /// Only kinds with at least one hit, in [SearchKind] order.
  final List<SearchGroup> groups;

  bool get isEmpty => groups.isEmpty;

  /// Every shown hit in display order, for keyboard navigation.
  List<SearchHit> get flat => [for (final g in groups) ...g.hits];
}
