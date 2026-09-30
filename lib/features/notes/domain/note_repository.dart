import 'note.dart';

/// Persistence for [Note] records.
///
/// Implementations throw `StorageException` on failure. Lists are returned
/// most recently updated first.
abstract interface class NoteRepository {
  Stream<List<Note>> watchAll();

  Stream<Note?> watchById(String id);

  Future<List<Note>> getAll();

  Future<Note?> getById(String id);

  /// Inserts or replaces the note with the same id.
  Future<void> save(Note note);

  Future<void> saveAll(Iterable<Note> notes);

  Future<void> delete(String id);

  Future<void> deleteAll(Iterable<String> ids);

  /// Unlinks [categoryId] from every note; returns the changed ids.
  Future<List<String>> clearCategory(String categoryId);

  Future<void> assignCategory(String categoryId, Iterable<String> ids);

  /// Unlinks [resourceId] from every note; returns the changed ids.
  Future<List<String>> clearResource(String resourceId);

  Future<void> assignResource(String resourceId, Iterable<String> ids);

  /// Unlinks [taskId] from every note; returns the changed ids.
  Future<List<String>> clearTask(String taskId);

  Future<void> assignTask(String taskId, Iterable<String> ids);
}
