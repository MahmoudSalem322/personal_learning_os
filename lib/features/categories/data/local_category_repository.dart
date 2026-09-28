import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_guard.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

/// [CategoryRepository] backed by the local sembast database.
///
/// Records that can't be parsed (e.g. corrupted by an older build) are
/// skipped and logged instead of breaking the whole list.
class LocalCategoryRepository implements CategoryRepository {
  LocalCategoryRepository(this._db);

  final Database _db;

  StoreRef<String, Map<String, Object?>> get _store => AppStores.categories;

  @override
  Stream<List<Category>> watchAll() => _store
      .query()
      .onSnapshots(_db)
      .map(_parseAll)
      .transform(storageErrors('watch categories'));

  @override
  Stream<Category?> watchById(String id) => _store
      .record(id)
      .onSnapshot(_db)
      .map((snapshot) => snapshot == null ? null : _parse(snapshot.value))
      .transform(storageErrors('watch category $id'));

  @override
  Future<List<Category>> getAll() => guardStorage(
    'load categories',
    () async => _parseAll(await _store.find(_db)),
  );

  @override
  Future<Category?> getById(String id) =>
      guardStorage('load category $id', () async {
        final json = await _store.record(id).get(_db);
        return json == null ? null : _parse(json);
      });

  @override
  Future<void> save(Category category) => guardStorage(
    'save category ${category.id}',
    () => _store.record(category.id).put(_db, category.toJson()),
  );

  @override
  Future<void> saveAll(Iterable<Category> categories) => guardStorage(
    'save categories',
    () => _db.transaction((txn) async {
      for (final category in categories) {
        await _store.record(category.id).put(txn, category.toJson());
      }
    }),
  );

  @override
  Future<void> delete(String id) =>
      guardStorage('delete category $id', () => _store.record(id).delete(_db));

  @override
  Future<void> deleteAll(Iterable<String> ids) =>
      guardStorage('delete categories', () => _store.records(ids).delete(_db));

  static Category? _parse(Map<String, Object?> json) =>
      tryParseRecord('category', json, Category.fromJson);

  List<Category> _parseAll(
    List<RecordSnapshot<String, Map<String, Object?>>> records,
  ) {
    final categories = [for (final record in records) ?_parse(record.value)];
    categories.sort(_byName);
    return List.unmodifiable(categories);
  }

  static int _byName(Category a, Category b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byName != 0 ? byName : a.createdAt.compareTo(b.createdAt);
  }
}
