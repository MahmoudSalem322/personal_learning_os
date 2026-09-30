import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/presentation/categories_providers.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../resources/domain/resource.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../domain/dashboard_summary.dart';

/// Dashboard totals once every collection has loaded; an error if one
/// failed to load.
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final resources = ref.watch(resourcesProvider);
  final notes = ref.watch(notesProvider);
  final tasks = ref.watch(tasksProvider);

  final all = <AsyncValue<List<Object>>>[categories, resources, notes, tasks];
  for (final value in all) {
    if (value.hasError && !value.hasValue) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
    }
  }
  if (all.any((value) => !value.hasValue)) return const AsyncLoading();
  return AsyncData(
    DashboardStats.of(
      categories: categories.requireValue,
      resources: resources.requireValue,
      notes: notes.requireValue,
      tasks: tasks.requireValue,
    ),
  );
});

final continueLearningProvider = Provider<List<Resource>>(
  (ref) => DashboardSelectors.continueLearning(
    ref.watch(resourcesProvider).value ?? const [],
  ),
);

final recentResourcesProvider = Provider<List<Resource>>(
  (ref) => DashboardSelectors.recentResources(
    ref.watch(resourcesProvider).value ?? const [],
  ),
);

/// Open tasks due today or overdue, as of when the tasks last changed.
final todaysTasksProvider = Provider<List<Task>>(
  (ref) => DashboardSelectors.todaysTasks(
    ref.watch(tasksProvider).value ?? const [],
    DateTime.now(),
  ),
);

final categoryProgressListProvider = Provider<List<CategoryProgress>>(
  (ref) => DashboardSelectors.categoryProgress(
    ref.watch(categoriesProvider).value ?? const [],
    ref.watch(categoryProgressProvider),
  ),
);

final favoritesPreviewProvider = Provider<List<FavoriteItem>>(
  (ref) => DashboardSelectors.favorites(
    resources: ref.watch(resourcesProvider).value ?? const [],
    notes: ref.watch(notesProvider).value ?? const [],
    tasks: ref.watch(tasksProvider).value ?? const [],
  ),
);
