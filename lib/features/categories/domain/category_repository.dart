import 'category.dart';

/// Persistence for [Category] records.
///
/// Implementations throw `StorageException` on failure. Lists are returned
/// sorted by name (case-insensitive). The interface is storage-agnostic so a
/// synced implementation can replace the local one later.
abstract interface class CategoryRepository {
  /// Emits the current list immediately and again after every change.
  Stream<List<Category>> watchAll();

  /// Emits the category (or `null` if it doesn't exist) and every change.
  Stream<Category?> watchById(String id);

  Future<List<Category>> getAll();

  Future<Category?> getById(String id);

  /// Inserts or replaces the category with the same id.
  Future<void> save(Category category);

  Future<void> saveAll(Iterable<Category> categories);

  Future<void> delete(String id);

  Future<void> deleteAll(Iterable<String> ids);
}
