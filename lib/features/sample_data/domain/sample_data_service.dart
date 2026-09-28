import '../../categories/domain/category.dart';
import '../../categories/domain/category_repository.dart';

/// Optional demo content that shows how the app works.
///
/// Sample records are recognized by their id prefix, so they can be removed
/// later without touching anything the user created. Later phases add
/// sample resources, notes and tasks the same way.
class SampleDataService {
  SampleDataService(this._categories);

  static const String idPrefix = 'sample-';

  static bool isSampleId(String id) => id.startsWith(idPrefix);

  final CategoryRepository _categories;

  /// Adds [categories] that don't clash with existing ones (same id or same
  /// name), so loading twice or after creating "Flutter" yourself is safe.
  /// Returns how many were added.
  Future<int> load({required List<Category> categories}) async {
    assert(categories.every((c) => isSampleId(c.id)));
    final existing = await _categories.getAll();
    final ids = existing.map((c) => c.id).toSet();
    final names = existing.map((c) => c.name.toLowerCase()).toSet();
    final toAdd = categories
        .where(
          (c) => !ids.contains(c.id) && !names.contains(c.name.toLowerCase()),
        )
        .toList();
    if (toAdd.isNotEmpty) await _categories.saveAll(toAdd);
    return toAdd.length;
  }

  /// Deletes every sample record.
  Future<void> remove() async {
    final existing = await _categories.getAll();
    await _categories.deleteAll(existing.map((c) => c.id).where(isSampleId));
  }
}
