import '../../categories/domain/category_links.dart';
import '../../resources/domain/resource_links.dart';
import '../domain/task_repository.dart';

/// Deleting a category keeps its tasks (uncategorized); Undo re-links them.
class TaskCategoryLinks implements CategoryLinks {
  TaskCategoryLinks(this._tasks);

  final TaskRepository _tasks;

  @override
  Future<List<String>> detach(String categoryId) =>
      _tasks.clearCategory(categoryId);

  @override
  Future<void> reattach(String categoryId, List<String> itemIds) =>
      _tasks.assignCategory(categoryId, itemIds);
}

/// Deleting a resource keeps its tasks (unlinked); Undo re-links them.
class TaskResourceLinks implements ResourceLinks {
  TaskResourceLinks(this._tasks);

  final TaskRepository _tasks;

  @override
  Future<List<String>> detach(String resourceId) =>
      _tasks.clearResource(resourceId);

  @override
  Future<void> reattach(String resourceId, List<String> itemIds) =>
      _tasks.assignResource(resourceId, itemIds);
}
