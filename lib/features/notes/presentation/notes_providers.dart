import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/local_note_repository.dart';
import '../domain/note.dart';
import '../domain/note_filter.dart';
import '../domain/note_repository.dart';
import '../domain/note_service.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => LocalNoteRepository(ref.watch(appDatabaseProvider)),
);

final noteServiceProvider = Provider<NoteService>(
  (ref) => NoteService(ref.watch(noteRepositoryProvider)),
);

/// All notes, most recently updated first; updates live.
final notesProvider = StreamProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).watchAll(),
);

final noteByIdProvider = StreamProvider.family<Note?, String>(
  (ref, id) => ref.watch(noteRepositoryProvider).watchById(id),
);

/// Filters of the notes page, kept while navigating.
final noteFilterProvider = NotifierProvider<NoteFilterController, NoteFilter>(
  NoteFilterController.new,
);

class NoteFilterController extends Notifier<NoteFilter> {
  @override
  NoteFilter build() => const NoteFilter();

  void update(NoteFilter Function(NoteFilter current) change) =>
      state = change(state);

  void reset() => state = state.cleared();
}

/// Notes on the notes page. Blank notes (e.g. one still being created in
/// another tab) are hidden.
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final filter = ref.watch(noteFilterProvider);
  return ref
      .watch(notesProvider)
      .whenData((all) => filter.apply(all.where((n) => !n.isBlank).toList()));
});

final notesByCategoryProvider = Provider.family<AsyncValue<List<Note>>, String>(
  (ref, categoryId) => ref
      .watch(notesProvider)
      .whenData(
        (all) =>
            all.where((n) => n.categoryId == categoryId && !n.isBlank).toList(),
      ),
);

final notesByResourceProvider = Provider.family<AsyncValue<List<Note>>, String>(
  (ref, resourceId) => ref
      .watch(notesProvider)
      .whenData(
        (all) =>
            all.where((n) => n.resourceId == resourceId && !n.isBlank).toList(),
      ),
);

/// Tags used by notes, for filters and suggestions.
final noteTagsProvider = Provider<List<String>>((ref) {
  final notes = ref.watch(notesProvider).value ?? const [];
  return ({for (final n in notes) ...n.tags}.toList()..sort());
});
