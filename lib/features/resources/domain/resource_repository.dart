import 'resource.dart';

/// Persistence for [Resource] records.
///
/// Implementations throw `StorageException` on failure. Lists are returned
/// newest first (by creation time); screens apply their own sort.
abstract interface class ResourceRepository {
  /// Emits the current list immediately and again after every change.
  Stream<List<Resource>> watchAll();

  /// Emits the resource (or `null` if it doesn't exist) and every change.
  Stream<Resource?> watchById(String id);

  Future<List<Resource>> getAll();

  Future<Resource?> getById(String id);

  /// Inserts or replaces the resource with the same id.
  Future<void> save(Resource resource);

  Future<void> saveAll(Iterable<Resource> resources);

  Future<void> delete(String id);

  Future<void> deleteAll(Iterable<String> ids);

  /// Removes [categoryId] from every resource that has it, atomically.
  /// Returns the ids of the resources that changed.
  Future<List<String>> clearCategory(String categoryId);

  /// Sets [categoryId] on the given resources (those that still exist).
  Future<void> assignCategory(String categoryId, Iterable<String> ids);
}
