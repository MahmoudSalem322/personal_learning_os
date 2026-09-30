import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_card.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';
import 'package:personal_learning_os/features/tasks/domain/task_filter.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';
import 'package:personal_learning_os/features/tasks/presentation/widgets/task_form_dialog.dart';

import '../../helpers/test_app.dart';

/// Tall enough to show every dashboard section without scrolling.
const Size _tall = Size(1440, 2200);

Future<ProviderContainer> openWithSamples(
  WidgetTester tester, {
  Size size = _tall,
}) async {
  final container = await tester.pumpLearningOs(size: size);
  await tester.tapAndSettleIo(find.text('Load sample data'));
  return container;
}

void main() {
  testWidgets('first run shows a welcome with ways to start', (tester) async {
    await tester.pumpLearningOs();
    expect(find.text('Welcome to Qabas'), findsOneWidget);
    expect(find.text('New category'), findsOneWidget);
    expect(find.text('Add resource'), findsOneWidget);
    expect(find.text('Load sample data'), findsOneWidget);
  });

  testWidgets('header greets, shows the date and the quick actions', (
    tester,
  ) async {
    await tester.pumpLearningOs();
    expect(
      find.textContaining(RegExp('^Good (morning|afternoon|evening)\$')),
      findsOneWidget,
    );
    expect(find.textContaining(RegExp(r'\d{4}')), findsWidgets);
    expect(find.text('Quick add'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('stats and every section appear with data', (tester) async {
    await openWithSamples(tester);

    for (final label in [
      'Resources',
      'Notes',
      'Pending tasks',
      'Completed tasks',
      'Categories',
      'Overall progress',
      'Continue learning',
      "Today's tasks",
      'Learning progress',
      'Recent resources',
      'Favorites',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    // Started, unfinished sample resources.
    expect(find.byType(ResourceCard), findsNWidgets(3));
    // The overdue sample task is listed for today.
    expect(find.text('Finish the Dart language tour'), findsOneWidget);
  });

  testWidgets("completing a task from Today's tasks", (tester) async {
    final container = await openWithSamples(tester);

    await tester.tapAndSettleIo(
      find.bySemanticsLabel('Finish the Dart language tour').first,
    );

    final tasks = await tester.io(
      () => container.read(taskRepositoryProvider).getAll(),
    );
    expect(
      tasks
          .singleWhere((t) => t.id == 'sample-task-read-dart-tour')
          .isCompleted,
      isTrue,
    );
    expect(find.text('Finish the Dart language tour'), findsNothing);
  });

  testWidgets('stat tiles open the matching page', (tester) async {
    final container = await openWithSamples(tester);

    await tester.tap(find.bySemanticsLabel(RegExp('^Completed tasks: ')));
    await tester.pumpAndSettle();

    expect(container.read(appRouterProvider).state.uri.path, '/tasks');
    expect(container.read(taskFilterProvider).view, TaskView.completed);
  });

  testWidgets('quick add opens the task form', (tester) async {
    await tester.pumpLearningOs();

    await tester.tap(find.text('Quick add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Task').last);
    await tester.pumpAndSettle();

    expect(find.byType(TaskFormDialog), findsOneWidget);
  });

  testWidgets('fits on phones and in Arabic', (tester) async {
    final container = await openWithSamples(tester, size: TestViewports.mobile);
    expect(tester.takeException(), isNull);

    await tester.io(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLanguage(AppLanguage.arabic),
    );
    expect(find.text('مهام اليوم'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpLearningOs(size: const Size(320, 568));
    expect(tester.takeException(), isNull);
  });
}
