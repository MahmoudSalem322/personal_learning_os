import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../notes/data/note_links.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../tasks/data/task_links.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../data/local_resource_repository.dart';
import '../domain/learning_progress.dart';
import '../domain/resource.dart';
import '../domain/resource_filter.dart';
import '../domain/resource_repository.dart';
import '../domain/resource_service.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>(
  (ref) => LocalResourceRepository(ref.watch(appDatabaseProvider)),
);

/// Notes and tasks linked to a resource are kept when it is deleted.
final resourceServiceProvider = Provider<ResourceService>(
  (ref) => ResourceService(
    ref.watch(resourceRepositoryProvider),
    links: [
      NoteResourceLinks(ref.watch(noteRepositoryProvider)),
      TaskResourceLinks(ref.watch(taskRepositoryProvider)),
    ],
  ),
);

/// All resources, newest first; updates live after every change.
final resourcesProvider = StreamProvider<List<Resource>>(
  (ref) => ref.watch(resourceRepositoryProvider).watchAll(),
);

/// A single resource by id; `null` when it doesn't exist.
final resourceByIdProvider = StreamProvider.family<Resource?, String>(
  (ref, id) => ref.watch(resourceRepositoryProvider).watchById(id),
);

/// Filters of the resources page. Kept while navigating, so coming back
/// from a detail page restores the same view.
final resourceFilterProvider =
    NotifierProvider<ResourceFilterController, ResourceFilter>(
      ResourceFilterController.new,
    );

class ResourceFilterController extends Notifier<ResourceFilter> {
  @override
  ResourceFilter build() => const ResourceFilter();

  void update(ResourceFilter Function(ResourceFilter current) change) =>
      state = change(state);

  void reset() => state = state.cleared();
}

/// The resources page list: all resources with the current filter applied.
final filteredResourcesProvider = Provider<AsyncValue<List<Resource>>>((ref) {
  final filter = ref.watch(resourceFilterProvider);
  return ref.watch(resourcesProvider).whenData(filter.apply);
});

/// Resources of one category, most recently added first.
final resourcesByCategoryProvider =
    Provider.family<AsyncValue<List<Resource>>, String>(
      (ref, categoryId) => ref
          .watch(resourcesProvider)
          .whenData(
            (all) => all.where((r) => r.categoryId == categoryId).toList(),
          ),
    );

/// Progress per category id, computed once per change of the resources.
final categoryProgressProvider = Provider<Map<String, LearningProgress>>((ref) {
  final resources = ref.watch(resourcesProvider).value ?? const [];
  return LearningProgress.byCategory(resources);
});

/// Every tag in use, sorted, for filters and suggestions.
final allTagsProvider = Provider<List<String>>((ref) {
  final resources = ref.watch(resourcesProvider).value ?? const [];
  return ({for (final r in resources) ...r.tags}.toList()..sort());
});
