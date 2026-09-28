import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_guard.dart';
import '../domain/resource.dart';
import '../domain/resource_repository.dart';

/// [ResourceRepository] backed by the local sembast database.
class LocalResourceRepository implements ResourceRepository {
  LocalResourceRepository(this._db);

  final Database _db;

  StoreRef<String, Map<String, Object?>> get _store => AppStores.resources;

  static const String _categoryField = 'categoryId';

  @override
  Stream<List<Resource>> watchAll() => _store
      .query()
      .onSnapshots(_db)
      .map(_parseAll)
      .transform(storageErrors('watch resources'));

  @override
  Stream<Resource?> watchById(String id) => _store
      .record(id)
      .onSnapshot(_db)
      .map((snapshot) => snapshot == null ? null : _parse(snapshot.value))
      .transform(storageErrors('watch resource $id'));

  @override
  Future<List<Resource>> getAll() => guardStorage(
    'load resources',
    () async => _parseAll(await _store.find(_db)),
  );

  @override
  Future<Resource?> getById(String id) =>
      guardStorage('load resource $id', () async {
        final json = await _store.record(id).get(_db);
        return json == null ? null : _parse(json);
      });

  @override
  Future<void> save(Resource resource) => guardStorage(
    'save resource ${resource.id}',
    () => _store.record(resource.id).put(_db, resource.toJson()),
  );

  @override
  Future<void> saveAll(Iterable<Resource> resources) => guardStorage(
    'save resources',
    () => _db.transaction((txn) async {
      for (final resource in resources) {
        await _store.record(resource.id).put(txn, resource.toJson());
      }
    }),
  );

  @override
  Future<void> delete(String id) =>
      guardStorage('delete resource $id', () => _store.record(id).delete(_db));

  @override
  Future<void> deleteAll(Iterable<String> ids) =>
      guardStorage('delete resources', () => _store.records(ids).delete(_db));

  @override
  Future<List<String>> clearCategory(String categoryId) => guardStorage(
    'unlink category $categoryId',
    () => _db.transaction((txn) async {
      final keys = await _store.findKeys(
        txn,
        finder: Finder(filter: Filter.equals(_categoryField, categoryId)),
      );
      for (final key in keys) {
        await _store.record(key).update(txn, {_categoryField: null});
      }
      return keys;
    }),
  );

  @override
  Future<void> assignCategory(String categoryId, Iterable<String> ids) =>
      guardStorage(
        'link category $categoryId',
        () => _db.transaction((txn) async {
          for (final id in ids) {
            // update() is a no-op for records deleted in the meantime.
            await _store.record(id).update(txn, {_categoryField: categoryId});
          }
        }),
      );

  static Resource? _parse(Map<String, Object?> json) =>
      tryParseRecord('resource', json, Resource.fromJson);

  List<Resource> _parseAll(
    List<RecordSnapshot<String, Map<String, Object?>>> records,
  ) {
    final resources = [for (final record in records) ?_parse(record.value)];
    resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(resources);
  }
}
