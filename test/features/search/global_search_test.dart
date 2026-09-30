import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/notes/domain/note_draft.dart';
import 'package:personal_learning_os/features/notes/presentation/notes_providers.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/search/presentation/global_search_dialog.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';

import '../../helpers/test_app.dart';

Future<void> pressCtrlK(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Finder get searchField => find.descendant(
  of: find.byType(GlobalSearchDialog),
  matching: find.byType(TextField),
);

Future<ProviderContainer> seeded(
  WidgetTester tester, {
  Size size = TestViewports.desktop,
}) async {
  final container = await tester.pumpLearningOs(size: size);
  await tester.io(() async {
    await container
        .read(resourceServiceProvider)
        .create(
          const ResourceDraft(
            title: 'Riverpod guide',
            type: ResourceType.documentation,
            tags: ['flutter'],
          ),
        );
    await container
        .read(noteServiceProvider)
        .create(
          const NoteDraft(title: 'Riverpod select', content: 'rebuild less'),
        );
    await container
        .read(taskServiceProvider)
        .create(const TaskDraft(title: 'Learn Riverpod', tags: ['flutter']));
  });
  return container;
}

void main() {
  testWidgets('Ctrl+K opens search, Esc closes it', (tester) async {
    await tester.pumpLearningOs();

    await pressCtrlK(tester);
    expect(find.byType(GlobalSearchDialog), findsOneWidget);
    expect(find.text('Search everything'), findsOneWidget);

    // A second Ctrl+K doesn't stack another dialog.
    await pressCtrlK(tester);
    expect(find.byType(GlobalSearchDialog), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchDialog), findsNothing);
  });

  testWidgets('results are grouped by kind and open on tap', (tester) async {
    final container = await seeded(tester);
    await tester.tap(find.text('Search…').first);
    await tester.pumpAndSettle();

    await tester.enterText(searchField, 'riverpod');
    await tester.pumpAndSettle();
    expect(find.text('Resources · 1'), findsOneWidget);
    expect(find.text('Notes · 1'), findsOneWidget);
    expect(find.text('Tasks · 1'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(GlobalSearchDialog),
        matching: find.text('Riverpod guide', findRichText: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchDialog), findsNothing);
    expect(
      container.read(appRouterProvider).state.uri.path,
      startsWith('/resources/'),
    );
  });

  testWidgets('arrow keys and Enter open the selected result', (tester) async {
    final container = await seeded(tester);
    await pressCtrlK(tester);
    await tester.enterText(searchField, 'riverpod');
    await tester.pumpAndSettle();

    // First hit is the resource; ↓ moves to the note, ↓ again to the task.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      container.read(appRouterProvider).state.uri.path,
      startsWith('/tasks/'),
    );
  });

  testWidgets('# searches tags; picking a tag narrows to it', (tester) async {
    await seeded(tester);
    await pressCtrlK(tester);

    await tester.enterText(searchField, '#');
    await tester.pumpAndSettle();
    expect(find.text('#flutter'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);

    await tester.tap(find.text('#flutter'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(searchField).controller!.text, '#flutter');
    expect(find.text('Resources · 1'), findsOneWidget);
    expect(find.text('Tasks · 1'), findsOneWidget);
    expect(find.text('Notes · 1'), findsNothing);
  });

  testWidgets('no results message', (tester) async {
    await seeded(tester);
    await pressCtrlK(tester);
    await tester.enterText(searchField, 'kubernetes');
    await tester.pumpAndSettle();
    expect(find.text('No results for "kubernetes"'), findsOneWidget);
  });

  testWidgets('"Show all" opens the page with the same search', (tester) async {
    final container = await tester.pumpLearningOs();
    await tester.io(() async {
      final service = container.read(resourceServiceProvider);
      for (var i = 1; i <= 7; i++) {
        await service.create(
          ResourceDraft(title: 'Widget $i', type: ResourceType.article),
        );
      }
    });
    await pressCtrlK(tester);
    await tester.enterText(searchField, 'widget');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show all 7'));
    await tester.pumpAndSettle();

    expect(container.read(appRouterProvider).state.uri.path, '/resources');
    expect(container.read(resourceFilterProvider).query, 'widget');
    expect(find.widgetWithText(TextField, 'widget'), findsOneWidget);
  });

  testWidgets('phones open search from the top bar', (tester) async {
    await tester.pumpLearningOs(size: TestViewports.mobile);
    await tester.tap(find.byTooltip('Search (Ctrl K)'));
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
