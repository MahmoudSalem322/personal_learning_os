import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/local_task_repository.dart';
import '../domain/task.dart';
import '../domain/task_filter.dart';
import '../domain/task_repository.dart';
import '../domain/task_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => LocalTaskRepository(ref.watch(appDatabaseProvider)),
);

final taskServiceProvider = Provider<TaskService>(
  (ref) => TaskService(ref.watch(taskRepositoryProvider)),
);

/// All tasks, most recently updated first; updates live.
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchAll(),
);

/// A single task by id; `null` when it doesn't exist.
final taskByIdProvider = StreamProvider.family<Task?, String>(
  (ref, id) => ref.watch(taskRepositoryProvider).watchById(id),
);

/// Filters of the tasks page, kept while navigating.
final taskFilterProvider = NotifierProvider<TaskFilterController, TaskFilter>(
  TaskFilterController.new,
);

class TaskFilterController extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => const TaskFilter();

  void update(TaskFilter Function(TaskFilter current) change) =>
      state = change(state);

  void reset() => state = state.cleared();
}

/// The tasks page list: all tasks with the current filter applied.
/// `now` anchors the date views, so they update as days pass.
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  return ref
      .watch(tasksProvider)
      .whenData((all) => filter.apply(all, now: DateTime.now()));
});

/// Tasks of one category: open ones by due date, then completed.
final tasksByCategoryProvider = Provider.family<AsyncValue<List<Task>>, String>(
  (ref, categoryId) => ref
      .watch(tasksProvider)
      .whenData(
        (all) =>
            all.where((t) => t.categoryId == categoryId).toList()
              ..sort(TaskFilter.compareOpenFirst),
      ),
);

/// Tasks linked to one resource: open ones by due date, then completed.
final tasksByResourceProvider = Provider.family<AsyncValue<List<Task>>, String>(
  (ref, resourceId) => ref
      .watch(tasksProvider)
      .whenData(
        (all) =>
            all.where((t) => t.resourceId == resourceId).toList()
              ..sort(TaskFilter.compareOpenFirst),
      ),
);

/// Tags used by tasks, for filters and suggestions.
final taskTagsProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? const [];
  return ({for (final t in tasks) ...t.tags}.toList()..sort());
});
