import 'package:sembast/sembast.dart';

import 'storage_guard.dart';

/// Typed access to one sembast store of JSON documents keyed by id.
///
/// Holds the plumbing every local repository needs (live queries, parsing
/// that skips unreadable records, error translation, bulk and link
/// updates), so repositories only map domain operations onto it.
class LocalDocumentStore<T> {
  LocalDocumentStore({
    required this._db,
    required this._store,
    required this._kind,
    required this._fromJson,
    required this._toJson,
    required this._idOf,
    required this._compare,
  });

  final Database _db;
  final StoreRef<String, Map<String, Object?>> _store;
  final String _kind;
  final T Function(Map<String, Object?> json) _fromJson;
  final Map<String, Object?> Function(T item) _toJson;
  final String Function(T item) _idOf;
  final int Function(T a, T b) _compare;

  /// Emits the sorted list immediately and after every change.
  Stream<List<T>> watchAll() => _store
      .query()
      .onSnapshots(_db)
      .map(_parseAll)
      .transform(storageErrors('watch ${_kind}s'));

  /// Emits the item (or `null` if missing) and every change to it.
  Stream<T?> watchById(String id) => _store
      .record(id)
      .onSnapshot(_db)
      .map((snapshot) => snapshot == null ? null : _parse(snapshot.value))
      .transform(storageErrors('watch $_kind $id'));

  Future<List<T>> getAll() => guardStorage(
    'load ${_kind}s',
    () async => _parseAll(await _store.find(_db)),
  );

  Future<T?> getById(String id) => guardStorage('load $_kind $id', () async {
    final json = await _store.record(id).get(_db);
    return json == null ? null : _parse(json);
  });

  Future<void> save(T item) => guardStorage(
    'save $_kind ${_idOf(item)}',
    () => _store.record(_idOf(item)).put(_db, _toJson(item)),
  );

  Future<void> saveAll(Iterable<T> items) => guardStorage(
    'save ${_kind}s',
    () => _db.transaction((txn) async {
      for (final item in items) {
        await _store.record(_idOf(item)).put(txn, _toJson(item));
      }
    }),
  );

  Future<void> delete(String id) =>
      guardStorage('delete $_kind $id', () => _store.record(id).delete(_db));

  Future<void> deleteAll(Iterable<String> ids) =>
      guardStorage('delete ${_kind}s', () => _store.records(ids).delete(_db));

  /// Sets [field] to `null` on every document where it equals [value],
  /// atomically. Returns the ids of the changed documents.
  Future<List<String>> clearField(String field, String value) => guardStorage(
    'unlink $field $value from ${_kind}s',
    () => _db.transaction((txn) async {
      final keys = await _store.findKeys(
        txn,
        finder: Finder(filter: Filter.equals(field, value)),
      );
      for (final key in keys) {
        await _store.record(key).update(txn, {field: null});
      }
      return keys;
    }),
  );

  /// Sets [field] to [value] on the given documents that still exist.
  Future<void> setField(String field, String value, Iterable<String> ids) =>
      guardStorage(
        'link $field $value to ${_kind}s',
        () => _db.transaction((txn) async {
          for (final id in ids) {
            // update() is a no-op for records deleted in the meantime.
            await _store.record(id).update(txn, {field: value});
          }
        }),
      );

  T? _parse(Map<String, Object?> json) =>
      tryParseRecord(_kind, json, _fromJson);

  List<T> _parseAll(
    List<RecordSnapshot<String, Map<String, Object?>>> records,
  ) {
    final items = [for (final record in records) ?_parse(record.value)];
    items.sort(_compare);
    return List.unmodifiable(items);
  }
}
