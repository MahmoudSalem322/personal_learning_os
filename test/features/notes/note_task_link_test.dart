import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/backup/domain/backup_snapshot.dart';
import 'package:personal_learning_os/features/notes/data/local_note_repository.dart';
import 'package:personal_learning_os/features/notes/data/note_links.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notes/domain/note_draft.dart';
import 'package:personal_learning_os/features/notes/domain/note_service.dart';
import 'package:personal_learning_os/features/notes/presentation/notes_providers.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/note_card.dart';
import 'package:personal_learning_os/features/tasks/data/local_task_repository.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/domain/task_service.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';
import 'package:sembast/sembast_memory.dart';

import '../../helpers/test_app.dart';

void main() {
  group('service', () {
    late Database db;
    late LocalNoteRepository notes;
    late NoteService noteService;
    late TaskService taskService;

    setUp(() async {
      db = await AppDatabase.open(newDatabaseFactoryMemory());
      notes = LocalNoteRepository(db);
      noteService = NoteService(notes);
      taskService = TaskService(
        LocalTaskRepository(db),
        links: [NoteTaskLinks(notes)],
      );
    });

    tearDown(() => db.close());

    test('a note keeps its task link through save and load', () async {
      final task = await taskService.create(const TaskDraft(title: 'Read'));
      final note = await noteService.create(
        NoteDraft(title: 'Summary', taskId: task.id),
      );
      expect((await notes.getById(note.id))!.taskId, task.id);
      expect(Note.fromJson(note.toJson()), note);
    });

    test('deleting a task keeps its notes; Undo re-links them', () async {
      final task = await taskService.create(const TaskDraft(title: 'Read'));
      final note = await noteService.create(
        NoteDraft(title: 'Summary', taskId: task.id),
      );

      final deleted = await taskService.delete(task.id);
      expect((await notes.getById(note.id))!.taskId, isNull);
      expect(deleted.detached.single, [note.id]);

      await taskService.restore(deleted);
      expect((await notes.getById(note.id))!.taskId, task.id);
    });

    test('backups drop links to tasks that are not in the file', () {
      final snapshot = BackupSnapshot(
        notes: [
          Note(
            id: 'n',
            title: 'x',
            taskId: 'missing',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ],
      ).withValidLinks();
      expect(snapshot.notes.single.taskId, isNull);
    });
  });

  testWidgets('a task page lists its notes', (tester) async {
    final container = await tester.pumpLearningOs(size: const Size(1440, 1600));
    final task = await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Build the todo app')),
    );
    container.read(appRouterProvider).go('/tasks/${task.id}');
    await tester.pumpAndSettle();
    expect(find.text('No notes for this task yet'), findsOneWidget);

    await tester.io(
      () => container
          .read(noteServiceProvider)
          .create(NoteDraft(title: 'Plan', content: 'x', taskId: task.id)),
    );
    expect(find.byType(NoteTile), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
  });
}
