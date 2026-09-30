import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/notes/domain/note_draft.dart';
import 'package:personal_learning_os/features/notes/presentation/notes_providers.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/note_card.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_card.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';
import 'package:personal_learning_os/features/tasks/presentation/widgets/task_card.dart';

import '../../helpers/test_app.dart';

Future<ProviderContainer> openFavorites(WidgetTester tester) async {
  final container = await tester.pumpLearningOs(size: const Size(1440, 1600));
  container.read(appRouterProvider).go('/favorites');
  await tester.pumpAndSettle();
  return container;
}

/// One starred item of each kind, plus one plain resource.
Future<void> seed(WidgetTester tester, ProviderContainer container) =>
    tester.io(() async {
      final resources = container.read(resourceServiceProvider);
      await resources.create(
        const ResourceDraft(
          title: 'Starred docs',
          type: ResourceType.documentation,
          isFavorite: true,
        ),
      );
      await resources.create(
        const ResourceDraft(title: 'Plain', type: ResourceType.article),
      );
      final note = await container
          .read(noteServiceProvider)
          .create(const NoteDraft(title: 'Starred note', content: 'x'));
      await container
          .read(noteServiceProvider)
          .setFavorite(note.id, favorite: true);
      final task = await container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Starred task'));
      await container
          .read(taskServiceProvider)
          .setFavorite(task.id, favorite: true);
    });

void main() {
  testWidgets('empty state explains how to add favorites', (tester) async {
    await openFavorites(tester);
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('lists starred resources, notes and tasks', (tester) async {
    final container = await openFavorites(tester);
    await seed(tester, container);

    expect(find.byType(ResourceCard), findsOneWidget);
    expect(find.text('Starred docs'), findsOneWidget);
    expect(find.text('Plain'), findsNothing);
    expect(find.byType(NoteCard), findsOneWidget);
    expect(find.byType(TaskCard), findsOneWidget);
    expect(find.text('All · 3'), findsOneWidget);
  });

  testWidgets('filters by kind', (tester) async {
    final container = await openFavorites(tester);
    await seed(tester, container);

    await tester.tap(find.text('Tasks · 1'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsOneWidget);
    expect(find.byType(ResourceCard), findsNothing);
    expect(find.byType(NoteCard), findsNothing);
  });

  testWidgets('unstarring removes the item', (tester) async {
    final container = await openFavorites(tester);
    await seed(tester, container);

    await tester.tapAndSettleIo(
      find.descendant(
        of: find.byType(TaskCard),
        matching: find.byTooltip('Remove from favorites'),
      ),
    );
    expect(find.byType(TaskCard), findsNothing);
    expect(find.text('All · 2'), findsOneWidget);
  });
}
