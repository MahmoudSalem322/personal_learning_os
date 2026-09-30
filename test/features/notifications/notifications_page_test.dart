import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_engine.dart';
import 'package:personal_learning_os/features/notifications/presentation/notification_scheduler.dart';
import 'package:personal_learning_os/features/notifications/presentation/notifications_providers.dart';
import 'package:personal_learning_os/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder.dart';
import 'package:personal_learning_os/features/reminders/presentation/reminders_providers.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';

import '../../helpers/test_app.dart';

/// Runs the notification engine now, as the scheduler would.
Future<List<AppNotification>> runEngine(
  WidgetTester tester,
  ProviderContainer container,
) => tester.io(
  () => container.read(notificationEngineProvider).run(DateTime.now()),
);

Future<Task> overdueTask(WidgetTester tester, ProviderContainer container) =>
    tester.io(
      () => container
          .read(taskServiceProvider)
          .create(
            TaskDraft(
              title: 'Read the Riverpod docs',
              dueDate: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ),
    );

Future<void> open(WidgetTester tester, ProviderContainer c, String path) async {
  c.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
}

class _CountingEngine implements NotificationEngine {
  int runs = 0;

  @override
  Future<List<AppNotification>> run(DateTime now) async {
    runs++;
    return const [];
  }
}

void main() {
  testWidgets('new notifications: toast, badge and inbox', (tester) async {
    final container = await tester.pumpLearningOs();
    await overdueTask(tester, container);

    final created = await runEngine(tester, container);
    expect(created, hasLength(2), reason: 'welcome + overdue');

    // In-app channel: a toast that links to the inbox.
    expect(find.text('2 new notifications'), findsOneWidget);
    expect(container.read(unreadCountProvider), 2);
    expect(find.bySemanticsLabel('Notifications, 2'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).state.uri.path, '/notifications');
    expect(find.byType(NotificationTile), findsNWidgets(2));
    expect(find.text('Inbox (2)'), findsOneWidget);
    expect(find.text('Overdue task'), findsOneWidget);
    expect(
      find.textContaining('"Read the Riverpod docs" was due'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a notification reads it and opens the task', (
    tester,
  ) async {
    final container = await tester.pumpLearningOs();
    final task = await overdueTask(tester, container);
    await runEngine(tester, container);
    await open(tester, container, '/notifications');

    await tester.tapAndSettleIo(find.text('Overdue task'));

    expect(
      container.read(appRouterProvider).state.uri.path,
      '/tasks/${task.id}',
    );
    final stored = await tester.io(
      () => container.read(notificationRepositoryProvider).getAll(),
    );
    expect(
      stored.singleWhere((n) => n.type == NotificationType.overdueTask).isRead,
      isTrue,
    );
  });

  testWidgets('mark all read, clear all and undo', (tester) async {
    final container = await tester.pumpLearningOs();
    await overdueTask(tester, container);
    await runEngine(tester, container);
    await open(tester, container, '/notifications');

    await tester.tapAndSettleIo(find.text('Mark all as read'));
    expect(container.read(unreadCountProvider), 0);
    expect(find.text('Mark all as read'), findsNothing);

    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Clear all'));
    expect(find.text("You're all caught up"), findsOneWidget);

    await tester.tapAndSettleIo(find.text('Undo'));
    expect(find.byType(NotificationTile), findsNWidgets(2));
  });

  testWidgets('preferences turn notifications off', (tester) async {
    final container = await tester.pumpLearningOs();
    await open(tester, container, '/notifications');

    await tester.tap(find.byTooltip('Notification preferences'));
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(find.text('Allow notifications'));
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingsControllerProvider).notifications.enabled,
      isFalse,
    );
    expect(
      find.text('Notifications are turned off. Nothing new will be added.'),
      findsOneWidget,
    );
    expect(await runEngine(tester, container), isEmpty);
  });

  testWidgets('schedule a learning session from the reminders tab', (
    tester,
  ) async {
    final container = await tester.pumpLearningOs();
    await open(tester, container, '/notifications');
    await tester.tap(find.text('Reminders').first);
    await tester.pumpAndSettle();
    expect(find.text('No reminders yet'), findsOneWidget);

    await tester.tap(find.text('New reminder').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Set reminder'));
    await tester.pumpAndSettle();
    expect(find.text('Describe the learning session'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'What do you want to learn?'),
      'Practice layouts',
    );
    await tester.tap(find.text('Every day'));
    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'Set reminder'),
    );

    final stored = await tester.io(
      () => container.read(reminderRepositoryProvider).getAll(),
    );
    expect(stored.single.title, 'Practice layouts');
    expect(stored.single.repeat, ReminderRepeat.daily);
    expect(stored.single.target, ReminderTarget.session);
    expect(find.textContaining('Reminder set for'), findsOneWidget);
    expect(find.text('Practice layouts'), findsOneWidget);
  });

  testWidgets('"Remind me" on a task page', (tester) async {
    final container = await tester.pumpLearningOs(size: const Size(1440, 1400));
    final task = await tester.io(
      () => container
          .read(taskServiceProvider)
          .create(const TaskDraft(title: 'Build a todo app')),
    );
    await open(tester, container, '/tasks/${task.id}');
    expect(find.text('No reminders yet.'), findsOneWidget);

    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    expect(find.text('Note (optional)'), findsOneWidget);
    await tester.tap(find.text('Tomorrow morning'));
    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'Set reminder'),
    );

    final stored = await tester.io(
      () => container.read(reminderRepositoryProvider).getAll(),
    );
    expect(stored.single.target, ReminderTarget.task);
    expect(stored.single.targetId, task.id);
    expect(stored.single.remindAt.toLocal().hour, 9);
    expect(find.text('No reminders yet.'), findsNothing);
  });

  testWidgets('fits on phones and in Arabic', (tester) async {
    final container = await tester.pumpLearningOs(size: TestViewports.mobile);
    await overdueTask(tester, container);
    await runEngine(tester, container);
    await open(tester, container, '/notifications');
    expect(tester.takeException(), isNull);

    await tester.io(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLanguage(AppLanguage.arabic),
    );
    expect(find.text('مهمة متأخرة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scheduler: runs after start, on changes and every minute', (
    tester,
  ) async {
    final engine = _CountingEngine();
    final scheduler = NotificationScheduler(engine)..start();
    addTearDown(scheduler.dispose);

    await tester.pump(const Duration(seconds: 2));
    expect(engine.runs, 1);

    scheduler
      ..requestRun()
      ..requestRun()
      ..requestRun();
    await tester.pump(const Duration(seconds: 2));
    expect(engine.runs, 2, reason: 'bursts are coalesced');

    await tester.pump(const Duration(minutes: 1));
    expect(engine.runs, 3);

    scheduler.dispose();
    await tester.pump(const Duration(minutes: 2));
    expect(engine.runs, 3);
  });
}
