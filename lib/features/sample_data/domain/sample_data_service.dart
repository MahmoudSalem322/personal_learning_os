import '../../categories/domain/category.dart';
import '../../categories/domain/category_repository.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_repository.dart';
import '../../resources/domain/resource.dart';
import '../../resources/domain/resource_repository.dart';

/// Optional demo content that shows how the app works.
///
/// Sample records are recognized by their id prefix, so they can be removed
/// later without touching anything the user created. Later phases add
/// sample tasks the same way.
class SampleDataService {
  SampleDataService({
    required this._categories,
    required this._resources,
    required this._notes,
  });

  static const String idPrefix = 'sample-';

  static bool isSampleId(String id) => id.startsWith(idPrefix);

  final CategoryRepository _categories;
  final ResourceRepository _resources;
  final NoteRepository _notes;

  /// Adds the samples that don't clash with existing data, so loading twice
  /// or after creating "Flutter" yourself is safe. Samples whose category or
  /// resource was skipped are added without that link.
  ///
  /// Returns how many records were added.
  Future<int> load({
    required List<Category> categories,
    required List<Resource> resources,
    List<Note> notes = const [],
  }) async {
    assert(
      [
        ...categories.map((c) => c.id),
        ...resources.map((r) => r.id),
        ...notes.map((n) => n.id),
      ].every(isSampleId),
    );

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
    final availableCategories = {
      ...categoryIds,
      ...newCategories.map((c) => c.id),
    };

    final resourceIds = (await _resources.getAll()).map((r) => r.id).toSet();
    final newResources = [
      for (final r in resources)
        if (!resourceIds.contains(r.id))
          availableCategories.contains(r.categoryId)
              ? r
              : r.copyWith(categoryId: null),
    ];
    final availableResources = {
      ...resourceIds,
      ...newResources.map((r) => r.id),
    };

    final noteIds = (await _notes.getAll()).map((n) => n.id).toSet();
    final newNotes = [
      for (final n in notes)
        if (!noteIds.contains(n.id))
          n.copyWith(
            categoryId: availableCategories.contains(n.categoryId)
                ? n.categoryId
                : null,
            resourceId: availableResources.contains(n.resourceId)
                ? n.resourceId
                : null,
          ),
    ];

    if (newCategories.isNotEmpty) await _categories.saveAll(newCategories);
    if (newResources.isNotEmpty) await _resources.saveAll(newResources);
    if (newNotes.isNotEmpty) await _notes.saveAll(newNotes);
    return newCategories.length + newResources.length + newNotes.length;
  }

  /// Deletes every sample record. The user's own items that were linked to
  /// sample categories or resources are kept and lose that link.
  Future<void> remove() async {
    List<String> sampleIds(Iterable<String> ids) =>
        ids.where(isSampleId).toList();

    await _notes.deleteAll(sampleIds((await _notes.getAll()).map((n) => n.id)));

    final resources = sampleIds((await _resources.getAll()).map((r) => r.id));
    for (final id in resources) {
      await _notes.clearResource(id);
    }
    await _resources.deleteAll(resources);

    final categories = sampleIds((await _categories.getAll()).map((c) => c.id));
    for (final id in categories) {
      await _resources.clearCategory(id);
      await _notes.clearCategory(id);
    }
    await _categories.deleteAll(categories);
  }
}
