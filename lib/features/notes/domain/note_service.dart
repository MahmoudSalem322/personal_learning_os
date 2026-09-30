import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import '../../tags/domain/tags.dart';
import 'note.dart';
import 'note_draft.dart';
import 'note_repository.dart';

/// Use cases for notes: creation, autosave updates, favorites, delete and
/// restore.
class NoteService {
  NoteService(this._repository, {IdGenerator? ids, DateTime Function()? clock})
    : _ids = ids ?? IdGenerator(),
      _clock = clock ?? DateTime.now;

  final NoteRepository _repository;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  static Set<NoteFieldError> validate(NoteDraft draft) {
    final d = draft.normalized();
    return {
      if (d.title.length > NoteRules.titleMaxLength)
        NoteFieldError.titleTooLong,
      if (d.content.length > NoteRules.contentMaxLength)
        NoteFieldError.contentTooLong,
      if (d.tags.length > TagRules.maxPerItem) NoteFieldError.tooManyTags,
    };
  }

  /// Creates a note right away (possibly blank) so the editor can open on
  /// it and autosave into it.
  Future<Note> create([NoteDraft draft = const NoteDraft()]) async {
    final d = _validated(draft);
    final now = _clock();
    final note = Note(
      id: _ids.next(),
      title: d.title,
      content: d.content,
      categoryId: d.categoryId,
      resourceId: d.resourceId,
      tags: d.tags,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(note);
    return note;
  }

  /// Saves the editable fields; favorites and createdAt are kept from the
  /// stored note. Unchanged drafts don't touch updatedAt.
  Future<Note> update(String id, NoteDraft draft) async {
    final current = await _require(id);
    final d = _validated(draft);
    final updated = current.copyWith(
      title: d.title,
      content: d.content,
      categoryId: d.categoryId,
      resourceId: d.resourceId,
      tags: d.tags,
      updatedAt: _clock(),
    );
    if (updated.copyWith(updatedAt: current.updatedAt) == current) {
      return current;
    }
    await _repository.save(updated);
    return updated;
  }

  Future<Note> setFavorite(String id, {required bool favorite}) async {
    final current = await _require(id);
    if (current.isFavorite == favorite) return current;
    final updated = current.copyWith(isFavorite: favorite);
    await _repository.save(updated);
    return updated;
  }

  /// Deletes the note and returns it so the caller can offer Undo.
  Future<Note> delete(String id) async {
    final current = await _require(id);
    await _repository.delete(id);
    return current;
  }

  Future<void> restore(Note note) => _repository.save(note);

  /// Removes the note if nothing was ever written in it. Used when leaving
  /// the editor of a freshly created note. Returns whether it was removed.
  Future<bool> discardIfBlank(String id) async {
    final current = await _repository.getById(id);
    if (current == null || !current.isBlank) return false;
    await _repository.delete(id);
    return true;
  }

  NoteDraft _validated(NoteDraft draft) {
    final errors = validate(draft);
    if (errors.isNotEmpty) throw NoteValidationException(errors);
    return draft.normalized();
  }

  Future<Note> _require(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Note $id not found');
    return current;
  }
}
