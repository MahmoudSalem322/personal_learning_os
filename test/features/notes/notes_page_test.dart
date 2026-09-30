import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notes/domain/note_draft.dart';
import 'package:personal_learning_os/features/notes/presentation/notes_providers.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/markdown_view.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/note_card.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../../helpers/test_app.dart';

Future<ProviderContainer> open(
  WidgetTester tester,
  String path, {
  Size size = TestViewports.desktop,
}) async {
  final container = await tester.pumpLearningOs(size: size);
  container.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
  return container;
}

Future<List<Note>> storedNotes(WidgetTester tester, ProviderContainer c) =>
    tester.io(() => c.read(noteRepositoryProvider).getAll());

/// Waits past the autosave debounce and lets the save reach storage.
Future<void> letAutosave(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 700));
  await tester.io(() => Future<void>.delayed(Duration.zero));
}

/// Leaves the editor so its final save (on dispose) finishes before the
/// test ends.
Future<void> leaveEditor(
  WidgetTester tester,
  ProviderContainer container, [
  String path = '/notes',
]) async {
  container.read(appRouterProvider).go(path);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.io(() => Future<void>.delayed(Duration.zero));
}

/// Unmounts the app so editors kept alive by the shell (inactive branches)
/// run their final save before the test ends.
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

Finder get titleField => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == 'Untitled',
);

Finder get contentField => find.byWidgetPredicate(
  (w) =>
      w is TextField &&
      w.decoration?.hintText == 'Start writing… Markdown is supported.',
);

void main() {
  testWidgets('empty state offers a new note and sample data', (tester) async {
    await open(tester, '/notes');
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Load sample data'), findsOneWidget);
  });

  testWidgets('new note: write, autosave, and it appears in the list', (
    tester,
  ) async {
    final container = await open(tester, '/notes');

    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'New note').first,
    );
    expect(
      container.read(appRouterProvider).state.uri.path,
      startsWith('/notes/'),
    );

    await tester.enterText(titleField, 'Riverpod');
    await tester.enterText(contentField, '- [ ] learn select');
    await letAutosave(tester);
    expect(find.text('Saved'), findsOneWidget);

    final saved = await storedNotes(tester, container);
    expect(saved.single.title, 'Riverpod');
    expect(saved.single.content, '- [ ] learn select');

    await tester.tap(find.text('All notes'));
    await tester.io(() => Future<void>.delayed(Duration.zero));
    expect(find.byType(NoteCard), findsOneWidget);
    expect(find.text('0/1 done'), findsOneWidget);
  });

  testWidgets('leaving a blank new note discards it', (tester) async {
    final container = await open(tester, '/notes');

    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'New note').first,
    );
    await tester.tap(find.text('All notes'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    expect(await storedNotes(tester, container), isEmpty);
    expect(find.text('No notes yet'), findsOneWidget);
  });

  testWidgets('preview renders markdown and checkboxes update the note', (
    tester,
  ) async {
    final container = await open(tester, '/notes');
    final note = await tester.io(
      () => container
          .read(noteServiceProvider)
          .create(
            const NoteDraft(title: 'Tasks', content: '# Plan\n\n- [ ] one'),
          ),
    );
    container.read(appRouterProvider).go('/notes/${note.id}');
    await tester.pumpAndSettle();

    // Existing notes open in preview.
    expect(find.byType(MarkdownView), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await letAutosave(tester);

    final saved = await storedNotes(tester, container);
    expect(saved.single.content, '# Plan\n\n- [x] one');
    await leaveEditor(tester, container);
  });

  testWidgets('toolbar formats the selection', (tester) async {
    final container = await open(tester, '/notes');
    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'New note').first,
    );

    await tester.enterText(contentField, 'item');
    await tester.tap(find.byTooltip('Bulleted list'));
    await tester.pump();

    final field = tester.widget<TextField>(contentField);
    expect(field.controller!.text, '- item');
    await leaveEditor(tester, container);
  });

  testWidgets('favorite and delete with Undo from the editor', (tester) async {
    final container = await open(tester, '/notes');
    final note = await tester.io(
      () => container
          .read(noteServiceProvider)
          .create(const NoteDraft(title: 'Keep me', content: 'text')),
    );
    container.read(appRouterProvider).go('/notes/${note.id}');
    await tester.pumpAndSettle();

    await tester.tapAndSettleIo(find.byTooltip('Add to favorites'));
    expect((await storedNotes(tester, container)).single.isFavorite, isTrue);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Delete'));
    expect(container.read(appRouterProvider).state.uri.path, '/notes');
    expect(await storedNotes(tester, container), isEmpty);

    await tester.tapAndSettleIo(find.text('Undo'));
    expect(find.byType(NoteCard), findsOneWidget);
  });

  testWidgets('resource page lists its notes and creates linked ones', (
    tester,
  ) async {
    final container = await open(tester, '/resources');
    final resource = await tester.io(
      () => container
          .read(resourceServiceProvider)
          .create(
            const ResourceDraft(title: 'Docs', type: ResourceType.website),
          ),
    );
    container.read(appRouterProvider).go('/resources/${resource.id}');
    await tester.pumpAndSettle();
    expect(find.text('No notes for this resource yet'), findsOneWidget);

    await tester.tapAndSettleIo(find.widgetWithText(TextButton, 'New note'));
    await tester.enterText(titleField, 'Summary');
    await letAutosave(tester);

    final saved = await storedNotes(tester, container);
    expect(saved.single.resourceId, resource.id);

    await leaveEditor(tester, container, '/resources/${resource.id}');
    expect(find.byType(NoteTile), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('filters by search text', (tester) async {
    final container = await open(tester, '/notes');
    await tester.io(() async {
      final service = container.read(noteServiceProvider);
      await service.create(const NoteDraft(title: 'Layout', content: 'Row'));
      await service.create(const NoteDraft(title: 'Git', content: 'rebase'));
    });
    expect(find.text('2 notes'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search notes or #tag'),
      'rebase',
    );
    await tester.pumpAndSettle();
    expect(find.byType(NoteCard), findsOneWidget);
  });

  testWidgets('sample notes on mobile and in Arabic', (tester) async {
    final container = await open(tester, '/notes', size: TestViewports.mobile);
    await tester.tapAndSettleIo(find.text('Load sample data'));
    expect(find.byType(NoteCard), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.io(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLanguage(AppLanguage.arabic),
    );
    await tester.tap(find.byType(NoteCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await leaveEditor(tester, container);
  });
}
