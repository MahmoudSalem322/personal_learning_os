import 'task.dart';

/// Persistence for [Task] records.
///
/// Implementations throw `StorageException` on failure. Lists are returned
/// most recently updated first; screens apply their own sort.
abstract interface class TaskRepository {
  /// Emits the current list immediately and again after every change.
  Stream<List<Task>> watchAll();

  /// Emits the task (or `null` if it doesn't exist) and every change.
  Stream<Task?> watchById(String id);

  Future<List<Task>> getAll();

  Future<Task?> getById(String id);

  /// Inserts or replaces the task with the same id.
  Future<void> save(Task task);

  Future<void> saveAll(Iterable<Task> tasks);

  Future<void> delete(String id);

  Future<void> deleteAll(Iterable<String> ids);

  /// Unlinks [categoryId] from every task; returns the changed ids.
  Future<List<String>> clearCategory(String categoryId);

  Future<void> assignCategory(String categoryId, Iterable<String> ids);

  /// Unlinks [resourceId] from every task; returns the changed ids.
  Future<List<String>> clearResource(String resourceId);

  Future<void> assignResource(String resourceId, Iterable<String> ids);
}
