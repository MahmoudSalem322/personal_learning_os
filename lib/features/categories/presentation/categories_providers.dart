import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../notes/data/note_links.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../resources/data/resource_category_links.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../tasks/data/task_links.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../data/local_category_repository.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/category_service.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => LocalCategoryRepository(ref.watch(appDatabaseProvider)),
);

/// Features whose items reference categories. Deleting a category unlinks
/// their items instead of deleting them.
final categoryServiceProvider = Provider<CategoryService>(
  (ref) => CategoryService(
    ref.watch(categoryRepositoryProvider),
    links: [
      ResourceCategoryLinks(ref.watch(resourceRepositoryProvider)),
      NoteCategoryLinks(ref.watch(noteRepositoryProvider)),
      TaskCategoryLinks(ref.watch(taskRepositoryProvider)),
    ],
  ),
);

/// All categories sorted by name; updates live after every change.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Categories by id, for looking up the category of a resource.
final categoryMapProvider = Provider<Map<String, Category>>((ref) {
  final categories = ref.watch(categoriesProvider).value ?? const [];
  return {for (final c in categories) c.id: c};
});

/// A single category by id; `null` when it doesn't exist.
final categoryByIdProvider = StreamProvider.family<Category?, String>(
  (ref, id) => ref.watch(categoryRepositoryProvider).watchById(id),
);
