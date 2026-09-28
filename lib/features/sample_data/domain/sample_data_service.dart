import '../../categories/domain/category.dart';
import '../../categories/domain/category_repository.dart';
import '../../resources/domain/resource.dart';
import '../../resources/domain/resource_repository.dart';

/// Optional demo content that shows how the app works.
///
/// Sample records are recognized by their id prefix, so they can be removed
/// later without touching anything the user created. Later phases add
/// sample notes and tasks the same way.
class SampleDataService {
  SampleDataService({required this._categories, required this._resources});

  static const String idPrefix = 'sample-';

  static bool isSampleId(String id) => id.startsWith(idPrefix);

  final CategoryRepository _categories;
  final ResourceRepository _resources;

  /// Adds the samples that don't clash with existing data, so loading twice
  /// or after creating "Flutter" yourself is safe. Sample resources whose
  /// category was skipped are added without a category.
  ///
  /// Returns how many records were added.
  Future<int> load({
    required List<Category> categories,
    required List<Resource> resources,
  }) async {
    assert(categories.every((c) => isSampleId(c.id)));
    assert(resources.every((r) => isSampleId(r.id)));

    final existingCategories = await _categories.getAll();
    final categoryIds = existingCategories.map((c) => c.id).toSet();
    final names = existingCategories.map((c) => c.name.toLowerCase()).toSet();
    final newCategories = categories
        .where(
          (c) =>
              !categoryIds.contains(c.id) &&
              !names.contains(c.name.toLowerCase()),
        )
        .toList();
    final available = {...categoryIds, ...newCategories.map((c) => c.id)};

    final resourceIds = (await _resources.getAll()).map((r) => r.id).toSet();
    final newResources = [
      for (final r in resources)
        if (!resourceIds.contains(r.id))
          available.contains(r.categoryId) ? r : r.copyWith(categoryId: null),
    ];

    if (newCategories.isNotEmpty) await _categories.saveAll(newCategories);
    if (newResources.isNotEmpty) await _resources.saveAll(newResources);
    return newCategories.length + newResources.length;
  }

  /// Deletes every sample record. The user's own resources that were put in
  /// a sample category are kept and become uncategorized.
  Future<void> remove() async {
    final sampleResources = (await _resources.getAll())
        .map((r) => r.id)
        .where(isSampleId)
        .toList();
    await _resources.deleteAll(sampleResources);

    final sampleCategories = (await _categories.getAll())
        .map((c) => c.id)
        .where(isSampleId)
        .toList();
    for (final id in sampleCategories) {
      await _resources.clearCategory(id);
    }
    await _categories.deleteAll(sampleCategories);
  }
}
