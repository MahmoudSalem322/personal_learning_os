import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/note.dart';
import '../domain/note_repository.dart';

/// [NoteRepository] backed by the local sembast database.
class LocalNoteRepository implements NoteRepository {
  LocalNoteRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.notes,
        kind: 'note',
        fromJson: Note.fromJson,
        toJson: (n) => n.toJson(),
        idOf: (n) => n.id,
        compare: (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );

  final LocalDocumentStore<Note> _docs;

  static const String _categoryField = 'categoryId';
  static const String _resourceField = 'resourceId';
  static const String _taskField = 'taskId';

  @override
  Stream<List<Note>> watchAll() => _docs.watchAll();

  @override
  Stream<Note?> watchById(String id) => _docs.watchById(id);

  @override
  Future<List<Note>> getAll() => _docs.getAll();

  @override
  Future<Note?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(Note note) => _docs.save(note);

  @override
  Future<void> saveAll(Iterable<Note> notes) => _docs.saveAll(notes);

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

  @override
  Future<List<String>> clearTask(String taskId) =>
      _docs.clearField(_taskField, taskId);

  @override
  Future<void> assignTask(String taskId, Iterable<String> ids) =>
      _docs.setField(_taskField, taskId, ids);
}
