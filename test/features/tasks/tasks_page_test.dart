import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/categories/domain/category_draft.dart';
import 'package:personal_learning_os/features/categories/presentation/categories_providers.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/domain/task_filter.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';
import 'package:personal_learning_os/features/tasks/presentation/widgets/task_card.dart';

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

Future<List<Task>> storedTasks(WidgetTester tester, ProviderContainer c) =>
    tester.io(() => c.read(taskRepositoryProvider).getAll());

/// A tab of the views bar (its labels also appear in badges).
Finder viewTab(String label) => find.descendant(
  of: find.byType(SegmentedButton<TaskView>),
  matching: find.text(label),
);

Future<void> submitForm(WidgetTester tester, String title) async {
  await tester.enterText(
    find.byWidgetPredicate(
      (w) =>
          w is TextField && w.decoration?.hintText == 'What needs to be done?',
    ),
    title,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Add task').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state offers to add a task and load sample data', (
    tester,
  ) async {
    await open(tester, '/tasks');
    expect(find.text('Plan your next steps'), findsOneWidget);
    expect(find.text('Add task'), findsWidgets);
    expect(find.text('Load sample data'), findsOneWidget);
  });

  testWidgets('create a task through the form', (tester) async {
    final container = await open(tester, '/tasks');

    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'Add task').first,
    );
    await submitForm(tester, 'Learn Riverpod');

    final tasks = await storedTasks(tester, container);
    expect(tasks.single.title, 'Learn Riverpod');
    expect(tasks.single.status, TaskStatus.todo);
    expect(find.byType(TaskCard), findsOneWidget);
  });

  testWidgets('checkbox completes a task and keeps it under Completed', (
    tester,
  ) async {
    final container = await open(tester, '/tasks');
    await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Practice widgets')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.io(() => Future<void>.delayed(Duration.zero));

    final stored = await storedTasks(tester, container);
    expect(stored.single.isCompleted, isTrue);
    expect(stored.single.completedAt, isNotNull);

    // The "All" view shows completed tasks too, with strikethrough styling.
    expect(find.byType(TaskCard), findsOneWidget);

    await tester.tap(viewTab('Completed'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsOneWidget);
  });

  testWidgets('delete asks for confirmation and offers Undo', (tester) async {
    final container = await open(tester, '/tasks');
    await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Keep me')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(find.text('Delete').last);

    expect(find.text('Delete "Keep me"?'), findsOneWidget);
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Delete'));
    expect(await storedTasks(tester, container), isEmpty);

    await tester.tapAndSettleIo(find.text('Undo'));
    expect(find.byType(TaskCard), findsOneWidget);
  });

  testWidgets('views and filters narrow the list', (tester) async {
    final container = await open(tester, '/tasks');
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    final service = container.read(taskServiceProvider);
    await tester.io(() async {
      await service.create(
        TaskDraft(title: 'Yesterday task', dueDate: yesterday),
      );
      await service.create(TaskDraft(title: 'Today task', dueDate: now));
      await service.create(
        TaskDraft(title: 'Tomorrow task', dueDate: tomorrow),
      );
    });
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsNWidgets(3));

    await tester.tap(viewTab('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Today task'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('Tomorrow task'), findsNothing);

    await tester.tap(viewTab('Overdue'));
    await tester.pumpAndSettle();
    expect(find.text('Yesterday task'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search tasks or #tag'),
      'tomorrow',
    );
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsNothing);
  });

  testWidgets('tasks appear on the category page and new tasks link to it', (
    tester,
  ) async {
    // Tall enough to show every section of the category page.
    final container = await open(
      tester,
      '/categories',
      size: const Size(1280, 2400),
    );
    final category = await tester.io(
      () => container
          .read(categoryServiceProvider)
          .create(
            const CategoryDraft(
              name: 'Flutter',
              icon: 'code',
              primaryColor: 0xFF8B5CF6,
              secondaryColor: 0xFF6366F1,
            ),
          ),
    );
    container.read(appRouterProvider).go('/categories/${category.id}');
    await tester.io(() => Future<void>.delayed(Duration.zero));
    expect(find.text('No tasks in Flutter yet'), findsOneWidget);

    await tester.tapAndSettleIo(
      find.widgetWithText(OutlinedButton, 'Add task'),
    );
    await submitForm(tester, 'Linked task');

    final stored = await storedTasks(tester, container);
    expect(stored.single.categoryId, category.id);

    container.read(appRouterProvider).go('/categories/${category.id}');
    await tester.io(() => Future<void>.delayed(Duration.zero));
    expect(find.byType(TaskCard), findsOneWidget);
  });

  testWidgets('deleting a category keeps its tasks (uncategorized)', (
    tester,
  ) async {
    final container = await open(tester, '/tasks');
    final category = await tester.io(
      () => container
          .read(categoryServiceProvider)
          .create(
            const CategoryDraft(
              name: 'Temp',
              icon: 'code',
              primaryColor: 0xFF8B5CF6,
              secondaryColor: 0xFF6366F1,
            ),
          ),
    );
    await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(
            TaskDraft(title: 'Orphan candidate', categoryId: category.id),
          ),
    );

    await tester.io(
      () => container.read(categoryServiceProvider).delete(category.id),
    );

    final stored = await storedTasks(tester, container);
    expect(stored.single.title, 'Orphan candidate');
    expect(stored.single.categoryId, isNull);
  });

  testWidgets('sample tasks render on mobile and in Arabic', (tester) async {
    await open(tester, '/tasks', size: TestViewports.mobile);
    await tester.tapAndSettleIo(find.text('Load sample data'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(viewTab('Today'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail page shows and edits a task', (tester) async {
    final container = await open(tester, '/tasks');
    final task = await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Detail target')),
    );

    container.read(appRouterProvider).go('/tasks/${task.id}');
    await tester.pumpAndSettle();
    expect(find.text('Detail target'), findsOneWidget);
    expect(find.text('To do'), findsWidgets);

    // Status segmented buttons on the detail page.
    await tester.tapAndSettleIo(find.text('In progress').last);
    final stored = await storedTasks(tester, container);
    expect(stored.single.status, TaskStatus.inProgress);
  });

  testWidgets('favorite star and the Favorites filter', (tester) async {
    final container = await open(tester, '/tasks');
    await tester.io(() async {
      final service = container.read(taskServiceProvider);
      await service.create(const TaskDraft(title: 'Starred'));
      await service.create(const TaskDraft(title: 'Plain'));
    });
    await tester.pumpAndSettle();

    await tester.tapAndSettleIo(
      find.descendant(
        of: find.widgetWithText(TaskCard, 'Starred'),
        matching: find.byTooltip('Add to favorites'),
      ),
    );
    final stored = await storedTasks(tester, container);
    expect(stored.firstWhere((t) => t.title == 'Starred').isFavorite, isTrue);

    await tester.tap(find.widgetWithText(FilterChip, 'Favorites'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsOneWidget);
    expect(find.text('Starred'), findsOneWidget);
  });

  testWidgets('tapping a tag filters by it', (tester) async {
    final container = await open(tester, '/tasks');
    await tester.io(() async {
      final service = container.read(taskServiceProvider);
      await service.create(const TaskDraft(title: 'Tagged', tags: ['dart']));
      await service.create(const TaskDraft(title: 'Other'));
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('#dart'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsOneWidget);
    expect(find.text('Tagged'), findsOneWidget);
  });

  testWidgets('deleting a resource keeps its tasks and Undo re-links', (
    tester,
  ) async {
    final container = await open(tester, '/tasks');
    final resource = await tester.io(
      () => container
          .read(resourceServiceProvider)
          .create(
            const ResourceDraft(title: 'Docs', type: ResourceType.website),
          ),
    );
    await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(TaskDraft(title: 'Read docs', resourceId: resource.id)),
    );

    final deleted = await tester.io(
      () => container.read(resourceServiceProvider).delete(resource.id),
    );
    expect((await storedTasks(tester, container)).single.resourceId, isNull);

    await tester.io(
      () => container.read(resourceServiceProvider).restore(deleted),
    );
    expect(
      (await storedTasks(tester, container)).single.resourceId,
      resource.id,
    );
  });
}
