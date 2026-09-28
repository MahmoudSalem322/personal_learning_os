import 'package:flutter/foundation.dart' show immutable;

import 'resource.dart';

/// Progress buckets for filtering.
enum ProgressFilter { all, notStarted, inProgress, completed }

/// Sort orders for resource lists.
enum ResourceSort { recentlyAdded, recentlyOpened, title, progress }

/// What the resources list shows. Pure data; [apply] does the work.
@immutable
class ResourceFilter {
  const ResourceFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.tag,
    this.progress = ProgressFilter.all,
    this.favoritesOnly = false,
    this.sort = ResourceSort.recentlyAdded,
  });

  /// [categoryId] value that matches resources without a category.
  static const String uncategorized = '__uncategorized__';

  final String query;
  final ResourceType? type;

  /// A category id, [uncategorized], or `null` for any.
  final String? categoryId;
  final String? tag;
  final ProgressFilter progress;
  final bool favoritesOnly;
  final ResourceSort sort;

  /// Whether anything besides the search text and sort narrows the list.
  bool get hasFilters =>
      type != null ||
      categoryId != null ||
      tag != null ||
      progress != ProgressFilter.all ||
      favoritesOnly;

  bool get isEmpty => query.trim().isEmpty && !hasFilters;

  static const Object _unset = Object();

  /// Pass `null` for [type], [categoryId] or [tag] to clear that filter.
  ResourceFilter copyWith({
    String? query,
    Object? type = _unset,
    Object? categoryId = _unset,
    Object? tag = _unset,
    ProgressFilter? progress,
    bool? favoritesOnly,
    ResourceSort? sort,
  }) {
    return ResourceFilter(
      query: query ?? this.query,
      type: identical(type, _unset) ? this.type : type as ResourceType?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      tag: identical(tag, _unset) ? this.tag : tag as String?,
      progress: progress ?? this.progress,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }

  /// Keeps the search text and sort, clears everything else.
  ResourceFilter cleared() => ResourceFilter(query: query, sort: sort);

  bool matches(Resource r) {
    if (type != null && r.type != type) return false;
    if (categoryId == uncategorized) {
      if (r.categoryId != null) return false;
    } else if (categoryId != null && r.categoryId != categoryId) {
      return false;
    }
    if (tag != null && !r.tags.contains(tag)) return false;
    if (favoritesOnly && !r.isFavorite) return false;
    switch (progress) {
      case ProgressFilter.all:
        break;
      case ProgressFilter.notStarted:
        if (r.isStarted) return false;
      case ProgressFilter.inProgress:
        if (!r.isStarted || r.isCompleted) return false;
      case ProgressFilter.completed:
        if (!r.isCompleted) return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final term = q.startsWith('#') ? q.substring(1) : q;
    return r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q) ||
        r.url.toLowerCase().contains(q) ||
        r.tags.any((t) => t.contains(term));
  }

  /// Filtered and sorted copy of [resources].
  List<Resource> apply(List<Resource> resources) {
    final result = resources.where(matches).toList();
    result.sort(_comparator);
    return result;
  }

  int _comparator(Resource a, Resource b) {
    switch (sort) {
      case ResourceSort.recentlyAdded:
        return b.createdAt.compareTo(a.createdAt);
      case ResourceSort.recentlyOpened:
        // Opened ones first (most recent first), then never-opened by age.
        final ao = a.lastOpenedAt;
        final bo = b.lastOpenedAt;
        if (ao != null && bo != null) return bo.compareTo(ao);
        if (ao != null) return -1;
        if (bo != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      case ResourceSort.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case ResourceSort.progress:
        final byProgress = b.progress.compareTo(a.progress);
        return byProgress != 0
            ? byProgress
            : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ResourceFilter &&
      other.query == query &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.tag == tag &&
      other.progress == progress &&
      other.favoritesOnly == favoritesOnly &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(query, type, categoryId, tag, progress, favoritesOnly, sort);
}
