import 'dart:async';
import 'dart:developer' as developer;

import 'package:sembast/sembast.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/app_database.dart';
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
      .transform(_storageErrors('watch categories'));

  @override
  Stream<Category?> watchById(String id) => _store
      .record(id)
      .onSnapshot(_db)
      .map((snapshot) => snapshot == null ? null : _tryParse(snapshot.value))
      .transform(_storageErrors('watch category $id'));

  @override
  Future<List<Category>> getAll() =>
      _guard('load categories', () async => _parseAll(await _store.find(_db)));

  @override
  Future<Category?> getById(String id) => _guard('load category $id', () async {
    final json = await _store.record(id).get(_db);
    return json == null ? null : _tryParse(json);
  });

  @override
  Future<void> save(Category category) => _guard(
    'save category ${category.id}',
    () => _store.record(category.id).put(_db, category.toJson()),
  );

  @override
  Future<void> saveAll(Iterable<Category> categories) => _guard(
    'save categories',
    () => _db.transaction((txn) async {
      for (final category in categories) {
        await _store.record(category.id).put(txn, category.toJson());
      }
    }),
  );

  @override
  Future<void> delete(String id) =>
      _guard('delete category $id', () => _store.record(id).delete(_db));

  @override
  Future<void> deleteAll(Iterable<String> ids) =>
      _guard('delete categories', () => _store.records(ids).delete(_db));

  List<Category> _parseAll(
    List<RecordSnapshot<String, Map<String, Object?>>> records,
  ) {
    final categories = [for (final record in records) ?_tryParse(record.value)];
    categories.sort(_byName);
    return List.unmodifiable(categories);
  }

  static int _byName(Category a, Category b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byName != 0 ? byName : a.createdAt.compareTo(b.createdAt);
  }

  static Category? _tryParse(Map<String, Object?> json) {
    try {
      return Category.fromJson(json);
    } on FormatException catch (error) {
      developer.log(
        'Skipping unreadable category',
        name: 'storage',
        error: error,
      );
      return null;
    }
  }

  static Future<T> _guard<T>(String action, Future<T> Function() body) async {
    try {
      return await body();
    } catch (error, stackTrace) {
      throw StorageException(
        'Failed to $action',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  static StreamTransformer<T, T> _storageErrors<T>(String action) =>
      StreamTransformer.fromHandlers(
        handleError: (error, stackTrace, sink) => sink.addError(
          StorageException(
            'Failed to $action',
            cause: error,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
}
