import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

/// [TaskRepository] backed by the local sembast database.
class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.tasks,
        kind: 'task',
        fromJson: Task.fromJson,
        toJson: (t) => t.toJson(),
        idOf: (t) => t.id,
        compare: (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );

  final LocalDocumentStore<Task> _docs;

  static const String _categoryField = 'categoryId';
  static const String _resourceField = 'resourceId';

  @override
  Stream<List<Task>> watchAll() => _docs.watchAll();

  @override
  Stream<Task?> watchById(String id) => _docs.watchById(id);

  @override
  Future<List<Task>> getAll() => _docs.getAll();

  @override
  Future<Task?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(Task task) => _docs.save(task);

  @override
  Future<void> saveAll(Iterable<Task> tasks) => _docs.saveAll(tasks);

  @override
  Future<void> delete(String id) => _docs.delete(id);

  @override
  Future<void> deleteAll(Iterable<String> ids) => _docs.deleteAll(ids);

  @override
  Future<List<String>> clearCategory(String categoryId) =>
      _docs.clearField(_categoryField, categoryId);

  @override
  Future<void> assignCategory(String categoryId, Iterable<String> ids) =>
      _docs.setField(_categoryField, categoryId, ids);

  @override
  Future<List<String>> clearResource(String resourceId) =>
      _docs.clearField(_resourceField, resourceId);

  @override
  Future<void> assignResource(String resourceId, Iterable<String> ids) =>
      _docs.setField(_resourceField, resourceId, ids);
}
