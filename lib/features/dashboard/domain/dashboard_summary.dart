import 'package:flutter/foundation.dart' show immutable;

import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../resources/domain/learning_progress.dart';
import '../../resources/domain/resource.dart';
import '../../tasks/domain/task.dart';

/// Totals shown at the top of the dashboard.
@immutable
class DashboardStats {
  const DashboardStats({
    required this.resources,
    required this.notes,
    required this.pendingTasks,
    required this.completedTasks,
    required this.categories,
    required this.overallProgress,
  });

  /// Blank notes (just created, nothing typed) don't count.
  /// [overallProgress] follows the category rule (see [LearningProgress]):
  /// the rounded mean of every resource's progress, `null` without
  /// resources.
  factory DashboardStats.of({
    required List<Category> categories,
    required List<Resource> resources,
    required List<Note> notes,
    required List<Task> tasks,
  }) {
    final completed = tasks.where((t) => t.isCompleted).length;
    return DashboardStats(
      resources: resources.length,
      notes: notes.where((n) => !n.isBlank).length,
      pendingTasks: tasks.length - completed,
      completedTasks: completed,
      categories: categories.length,
      overallProgress: LearningProgress.of(resources).percent,
    );
  }

  final int resources;
  final int notes;
  final int pendingTasks;
  final int completedTasks;
  final int categories;

  /// 0–100, or `null` when there are no resources.
  final int? overallProgress;

  bool get isEmpty =>
      resources == 0 &&
      notes == 0 &&
      pendingTasks == 0 &&
      completedTasks == 0 &&
      categories == 0;

  @override
  bool operator ==(Object other) =>
      other is DashboardStats &&
      other.resources == resources &&
      other.notes == notes &&
      other.pendingTasks == pendingTasks &&
      other.completedTasks == completedTasks &&
      other.categories == categories &&
      other.overallProgress == overallProgress;

  @override
  int get hashCode => Object.hash(
    resources,
    notes,
    pendingTasks,
    completedTasks,
    categories,
    overallProgress,
  );
}

/// A category with its computed progress, for the progress section.
typedef CategoryProgress = ({Category category, LearningProgress progress});

/// A favorite item of any kind, for the favorites section.
@immutable
sealed class FavoriteItem {
  const FavoriteItem();

  DateTime get updatedAt;
}

final class FavoriteResource extends FavoriteItem {
  const FavoriteResource(this.resource);

  final Resource resource;

  @override
  DateTime get updatedAt => resource.updatedAt;
}

final class FavoriteNote extends FavoriteItem {
  const FavoriteNote(this.note);

  final Note note;

  @override
  DateTime get updatedAt => note.updatedAt;
}

final class FavoriteTask extends FavoriteItem {
  const FavoriteTask(this.task);

  final Task task;

  @override
  DateTime get updatedAt => task.updatedAt;
}

/// Picks what each dashboard section shows. Pure, so it's easy to test.
abstract final class DashboardSelectors {
  /// Started but unfinished resources, most recently opened first (never
  /// opened ones by last update).
  static List<Resource> continueLearning(
    List<Resource> resources, {
    int limit = 3,
  }) {
    DateTime activity(Resource r) => r.lastOpenedAt ?? r.updatedAt;
    final started =
        resources.where((r) => r.isStarted && !r.isCompleted).toList()
          ..sort((a, b) => activity(b).compareTo(activity(a)));
    return started.take(limit).toList();
  }

  /// Newest resources by creation date.
  static List<Resource> recentResources(
    List<Resource> resources, {
    int limit = 5,
  }) => ([
    ...resources,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(limit).toList();

  /// Open tasks due today or earlier: overdue first (oldest first), then
  /// by priority (high first).
  static List<Task> todaysTasks(List<Task> tasks, DateTime now) {
    return tasks.where((t) => t.isDueOn(now) || t.isOverdue(now)).toList()
      ..sort((a, b) {
        final byDate = a.dueDate!.compareTo(b.dueDate!);
        if (byDate != 0) return byDate;
        return b.priority.index.compareTo(a.priority.index);
      });
  }

  /// Categories that have resources, with their progress, by name.
  static List<CategoryProgress> categoryProgress(
    List<Category> categories,
    Map<String, LearningProgress> progress,
  ) {
    final list = [
      for (final c in categories)
        if (progress[c.id] case final p? when p.resourceCount > 0)
          (category: c, progress: p),
    ];
    list.sort(
      (a, b) => a.category.name.toLowerCase().compareTo(
        b.category.name.toLowerCase(),
      ),
    );
    return list;
  }

  /// Favorite resources, notes and tasks, most recently updated first.
  static List<FavoriteItem> favorites({
    required List<Resource> resources,
    required List<Note> notes,
    required List<Task> tasks,
    int limit = 6,
  }) {
    final items = <FavoriteItem>[
      for (final r in resources)
        if (r.isFavorite) FavoriteResource(r),
      for (final n in notes)
        if (n.isFavorite && !n.isBlank) FavoriteNote(n),
      for (final t in tasks)
        if (t.isFavorite) FavoriteTask(t),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.take(limit).toList();
  }
}
