import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/routing/app_transition_page.dart';
import 'pages/note_editor_page.dart';
import 'pages/notes_page.dart';

/// `/notes` and `/notes/:id`.
GoRoute notesRoute() => GoRoute(
  path: AppRoutes.notes,
  name: 'notes',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const NotesPage()),
  routes: [
    GoRoute(
      path: ':${AppRoutes.idParam}',
      name: 'note',
      pageBuilder: (context, state) => AppTransitionPage(
        key: state.pageKey,
        child: NoteEditorPage(noteId: state.pathParameters[AppRoutes.idParam]!),
      ),
    ),
  ],
);
