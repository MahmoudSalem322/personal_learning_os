import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/local_category_repository.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/category_service.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => LocalCategoryRepository(ref.watch(appDatabaseProvider)),
);

final categoryServiceProvider = Provider<CategoryService>(
  (ref) => CategoryService(ref.watch(categoryRepositoryProvider)),
);

/// All categories sorted by name; updates live after every change.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// A single category by id; `null` when it doesn't exist.
final categoryByIdProvider = StreamProvider.family<Category?, String>(
  (ref, id) => ref.watch(categoryRepositoryProvider).watchById(id),
);
