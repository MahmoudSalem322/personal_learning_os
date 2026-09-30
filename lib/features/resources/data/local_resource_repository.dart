import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/resource.dart';
import '../domain/resource_repository.dart';

/// [ResourceRepository] backed by the local sembast database.
class LocalResourceRepository implements ResourceRepository {
  LocalResourceRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.resources,
        kind: 'resource',
        fromJson: Resource.fromJson,
        toJson: (r) => r.toJson(),
        idOf: (r) => r.id,
        compare: (a, b) => b.createdAt.compareTo(a.createdAt),
      );

  final LocalDocumentStore<Resource> _docs;

  static const String _categoryField = 'categoryId';

  @override
  Stream<List<Resource>> watchAll() => _docs.watchAll();

  @override
  Stream<Resource?> watchById(String id) => _docs.watchById(id);

  @override
  Future<List<Resource>> getAll() => _docs.getAll();

  @override
  Future<Resource?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(Resource resource) => _docs.save(resource);

  @override
  Future<void> saveAll(Iterable<Resource> resources) =>
      _docs.saveAll(resources);

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
}
