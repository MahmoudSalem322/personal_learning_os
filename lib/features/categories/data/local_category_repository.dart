import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

/// [CategoryRepository] backed by the local sembast database.
///
/// Records that can't be parsed (e.g. corrupted by an older build) are
/// skipped and logged instead of breaking the whole list.
class LocalCategoryRepository implements CategoryRepository {
  LocalCategoryRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.categories,
        kind: 'category',
        fromJson: Category.fromJson,
        toJson: (c) => c.toJson(),
        idOf: (c) => c.id,
        compare: _byName,
      );

  final LocalDocumentStore<Category> _docs;

  @override
  Stream<List<Category>> watchAll() => _docs.watchAll();

  @override
  Stream<Category?> watchById(String id) => _docs.watchById(id);

  @override
  Future<List<Category>> getAll() => _docs.getAll();

  @override
  Future<Category?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(Category category) => _docs.save(category);

  @override
  Future<void> saveAll(Iterable<Category> categories) =>
      _docs.saveAll(categories);

  @override
  Future<void> delete(String id) => _docs.delete(id);

  @override
  Future<void> deleteAll(Iterable<String> ids) => _docs.deleteAll(ids);

  static int _byName(Category a, Category b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byName != 0 ? byName : a.createdAt.compareTo(b.createdAt);
  }
}
