import 'package:flutter/foundation.dart' show immutable;

import 'task.dart';

/// Predefined views of the tasks list, shown as tabs.
enum TaskView { all, today, upcoming, overdue, completed }

/// Sort orders for task lists.
enum TaskSort { dueDate, priority, recentlyCreated, recentlyUpdated }

/// What the tasks list shows. Pure data; [apply] does the work.
@immutable
class TaskFilter {
  const TaskFilter({
    this.query = '',
    this.view = TaskView.all,
    this.status,
    this.priority,
    this.categoryId,
    this.tag,
    this.favoritesOnly = false,
    this.sort = TaskSort.dueDate,
  });

  /// [categoryId] value that matches tasks without a category.
  static const String uncategorized = '__uncategorized__';

  final String query;
  final TaskView view;

  /// Extra status filter on top of the view. `null` shows all statuses the
  /// view allows.
  final TaskStatus? status;
  final TaskPriority? priority;

  /// A category id, [uncategorized], or `null` for any.
  final String? categoryId;

  /// A normalized tag, or `null` for any.
  final String? tag;
  final bool favoritesOnly;
  final TaskSort sort;

  /// Whether anything besides the search text and sort narrows the list.
  bool get hasFilters =>
      status != null ||
      priority != null ||
      categoryId != null ||
      tag != null ||
      favoritesOnly;

  static const Object _unset = Object();

  /// Pass `null` for [status], [priority] or [categoryId] to clear that
  /// filter.
  TaskFilter copyWith({
    String? query,
    TaskView? view,
    Object? status = _unset,
    Object? priority = _unset,
    Object? categoryId = _unset,
    Object? tag = _unset,
    bool? favoritesOnly,
    TaskSort? sort,
  }) {
    return TaskFilter(
      query: query ?? this.query,
      view: view ?? this.view,
      status: identical(status, _unset) ? this.status : status as TaskStatus?,
      priority: identical(priority, _unset)
          ? this.priority
          : priority as TaskPriority?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      tag: identical(tag, _unset) ? this.tag : tag as String?,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }

  /// Keeps the search text and sort, clears everything else and returns to
  /// the default view.
  TaskFilter cleared() => TaskFilter(query: query, sort: sort);

  bool matches(Task t, DateTime now) {
    switch (view) {
      case TaskView.all:
        break;
      case TaskView.today:
        if (!t.isDueOn(now)) return false;
      case TaskView.upcoming:
        if (t.isCompleted || t.dueDate == null || !t.dueDate!.isAfter(now)) {
          return false;
        }
      case TaskView.overdue:
        if (!t.isOverdue(now)) return false;
      case TaskView.completed:
        if (!t.isCompleted) return false;
    }
    if (status != null && t.status != status) return false;
    if (priority != null && t.priority != priority) return false;
    if (categoryId == uncategorized) {
      if (t.categoryId != null) return false;
    } else if (categoryId != null && t.categoryId != categoryId) {
      return false;
    }
    if (tag != null && !t.tags.contains(tag)) return false;
    if (favoritesOnly && !t.isFavorite) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final term = q.startsWith('#') ? q.substring(1) : q;
    return t.title.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q) ||
        t.tags.any((tag) => tag.contains(term));
  }

  /// Filtered and sorted copy of [tasks]; [now] anchors the date views.
  /// Completed tasks always come after open ones.
  List<Task> apply(List<Task> tasks, {required DateTime now}) {
    final result = tasks.where((t) => matches(t, now)).toList();
    result.sort(_compare);
    return result;
  }

  int _compare(Task a, Task b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return _compareBySort(a, b);
  }

  int _compareBySort(Task a, Task b) => switch (sort) {
    TaskSort.dueDate => _byDueDate(a, b),
    TaskSort.priority => _byPriority(a, b),
    TaskSort.recentlyCreated => b.createdAt.compareTo(a.createdAt),
    TaskSort.recentlyUpdated => b.updatedAt.compareTo(a.updatedAt),
  };

  /// Order for short lists (category and resource pages): open tasks by
  /// due date first, completed ones last.
  static int compareOpenFirst(Task a, Task b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return _byDueDate(a, b);
  }

  /// Tasks without a due date go last, the rest by date.
  static int _byDueDate(Task a, Task b) {
    final ad = a.dueDate;
    final bd = b.dueDate;
    if (ad != null && bd != null) return ad.compareTo(bd);
    if (ad != null) return -1;
    if (bd != null) return 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  /// High → medium → low, then by due date.
  static int _byPriority(Task a, Task b) {
    final byPriority = b.priority.index.compareTo(a.priority.index);
    return byPriority != 0 ? byPriority : _byDueDate(a, b);
  }

  @override
  bool operator ==(Object other) =>
      other is TaskFilter &&
      other.query == query &&
      other.view == view &&
      other.status == status &&
      other.priority == priority &&
      other.categoryId == categoryId &&
      other.tag == tag &&
      other.favoritesOnly == favoritesOnly &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    query,
    view,
    status,
    priority,
    categoryId,
    tag,
    favoritesOnly,
    sort,
  );
}
