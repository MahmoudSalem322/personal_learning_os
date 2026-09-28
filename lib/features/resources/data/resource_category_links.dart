import '../../categories/domain/category_links.dart';
import '../domain/resource_repository.dart';

/// Lets category deletion unlink resources (they stay in the library,
/// uncategorized) and Undo link them again.
class ResourceCategoryLinks implements CategoryLinks {
  ResourceCategoryLinks(this._resources);

  final ResourceRepository _resources;

  @override
  Future<List<String>> detach(String categoryId) =>
      _resources.clearCategory(categoryId);

  @override
  Future<void> reattach(String categoryId, List<String> itemIds) =>
      _resources.assignCategory(categoryId, itemIds);
}
