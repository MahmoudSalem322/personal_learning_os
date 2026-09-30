import '../../categories/domain/category_links.dart';
import '../../resources/domain/resource_links.dart';
import '../domain/note_repository.dart';

/// Deleting a category keeps its notes (uncategorized); Undo re-links them.
class NoteCategoryLinks implements CategoryLinks {
  NoteCategoryLinks(this._notes);

  final NoteRepository _notes;

  @override
  Future<List<String>> detach(String categoryId) =>
      _notes.clearCategory(categoryId);

  @override
  Future<void> reattach(String categoryId, List<String> itemIds) =>
      _notes.assignCategory(categoryId, itemIds);
}

/// Deleting a resource keeps its notes (unlinked); Undo re-links them.
class NoteResourceLinks implements ResourceLinks {
  NoteResourceLinks(this._notes);

  final NoteRepository _notes;

  @override
  Future<List<String>> detach(String resourceId) =>
      _notes.clearResource(resourceId);

  @override
  Future<void> reattach(String resourceId, List<String> itemIds) =>
      _notes.assignResource(resourceId, itemIds);
}
