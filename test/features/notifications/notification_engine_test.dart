import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/notifications/data/local_notification_repository.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_channel.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_engine.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_preferences.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_service.dart';
import 'package:personal_learning_os/features/reminders/data/local_reminder_repository.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/tasks/data/local_task_repository.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:sembast/sembast_memory.dart';

class _RecordingChannel implements NotificationChannel {
  final List<List<AppNotification>> batches = [];

  @override
  Future<void> deliver(List<AppNotification> notifications) async =>
      batches.add(notifications);
}

class _FailingChannel implements NotificationChannel {
  @override
  Future<void> deliver(List<AppNotification> notifications) =>
      Future.error(StateError('browser said no'));
}

void main() {
  late Database db;
  late LocalNotificationRepository notifications;
  late LocalReminderRepository reminders;
  late LocalTaskRepository tasks;
  late LocalResourceRepository resources;
  late _RecordingChannel channel;
  late NotificationPreferences prefs;
  late NotificationEngine engine;

  final t0 = DateTime(2026, 9, 1);
  final now = DateTime(2026, 9, 30, 10);
  final today = DateTime(2026, 9, 30);

  Task task(String id, {DateTime? due, TaskStatus status = TaskStatus.todo}) =>
      Task(
        id: id,
        title: 'Task $id',
        dueDate: due,
        status: status,
        createdAt: t0,
        updatedAt: t0,
      );

  Reminder reminder(
    String id, {
    required DateTime at,
    ReminderTarget target = ReminderTarget.session,
    String? targetId,
    String title = 'Practice',
    ReminderRepeat repeat = ReminderRepeat.none,
  }) => Reminder(
    id: id,
    target: target,
    targetId: targetId,
    title: title,
    remindAt: at,
    repeat: repeat,
    createdAt: t0,
    updatedAt: t0,
  );

  List<String> keys(Iterable<AppNotification> list) =>
      [for (final n in list) n.key]..sort();

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    notifications = LocalNotificationRepository(db);
    reminders = LocalReminderRepository(db);
    tasks = LocalTaskRepository(db);
    resources = LocalResourceRepository(db);
    channel = _RecordingChannel();
    prefs = NotificationPreferences.defaults;
    engine = NotificationEngine(
      notifications: notifications,
      reminders: reminders,
      tasks: tasks,
      resources: resources,
      preferences: () => prefs,
      channels: [_FailingChannel(), channel],
    );
  });

  tearDown(() => db.close());

  test('first run welcomes the user, once', () async {
    final first = await engine.run(now);
    expect(keys(first), [NotificationEngine.welcomeKey]);
    expect(first.single.notice, SystemNotice.welcome);
    expect(await engine.run(now), isEmpty);
  });

  test('upcoming and overdue task alerts, once per due date', () async {
    await tasks.saveAll([
      task('today', due: today),
      task('tomorrow', due: today.add(const Duration(days: 1))),
      task('later', due: today.add(const Duration(days: 5))),
      task('late', due: today.subtract(const Duration(days: 2))),
      task(
        'done',
        due: today.subtract(const Duration(days: 2)),
        status: TaskStatus.completed,
      ),
      task('no-date'),
    ]);

    final created = await engine.run(now);
    expect(keys(created), [
      'overdueTask:late:2026-09-28',
      NotificationEngine.welcomeKey,
      'upcomingTask:today:2026-09-30',
      'upcomingTask:tomorrow:2026-10-01',
    ]);
    expect(await engine.run(now), isEmpty, reason: 'no duplicates');

    // The next day "today" is overdue: one more alert for it.
    final nextDay = now.add(const Duration(days: 1));
    expect(keys(await engine.run(nextDay)), ['overdueTask:today:2026-09-30']);
  });

  test(
    'a reminder fires once; a repeating one moves to its next time',
    () async {
      await reminders.saveAll([
        reminder('once', at: now.subtract(const Duration(minutes: 5))),
        reminder(
          'daily',
          at: DateTime(2026, 9, 27, 8),
          repeat: ReminderRepeat.daily,
        ),
        reminder('future', at: now.add(const Duration(hours: 1))),
      ]);

      final created = await engine.run(now);
      final fired = created.where(
        (n) => n.type == NotificationType.learningReminder,
      );
      expect(fired, hasLength(2), reason: 'missed days fire once, not 3 times');
      expect(fired.map((n) => n.subject).toSet(), {'Practice'});

      final once = await reminders.getById('once');
      expect(once!.isFinished, isTrue);
      final daily = await reminders.getById('daily');
      expect(
        daily!.remindAt.isAtSameMomentAs(DateTime(2026, 10, 1, 8)),
        isTrue,
      );

      expect(
        (await engine.run(now))
            .where((n) => n.type == NotificationType.learningReminder),
        isEmpty,
      );
    },
  );

  test(
    'task and resource reminders use the item title; deleted items wait',
    () async {
      await tasks.save(task('t1'));
      await resources.save(
        Resource(
          id: 'res',
          title: 'Flutter docs',
          type: ResourceType.documentation,
          createdAt: t0,
          updatedAt: t0,
        ),
      );
      final due = now.subtract(const Duration(minutes: 1));
      await reminders.saveAll([
        reminder(
          'on-task',
          at: due,
          target: ReminderTarget.task,
          targetId: 't1',
          title: 'Chapter 3',
        ),
        reminder(
          'on-resource',
          at: due,
          target: ReminderTarget.resource,
          targetId: 'res',
          title: '',
        ),
        reminder(
          'on-deleted',
          at: due,
          target: ReminderTarget.task,
          targetId: 'gone',
        ),
      ]);

      final created = await engine.run(now);
      final byType = {for (final n in created) n.type: n};
      expect(byType[NotificationType.taskReminder]!.subject, 'Task t1');
      expect(byType[NotificationType.taskReminder]!.note, 'Chapter 3');
      expect(byType[NotificationType.taskReminder]!.targetId, 't1');
      expect(
        byType[NotificationType.learningReminder]!.subject,
        'Flutter docs',
      );

      final waiting = await reminders.getById('on-deleted');
      expect(
        waiting!.lastFiredAt,
        isNull,
        reason: 'fires if the task comes back',
      );

      await tasks.save(task('gone'));
      expect(
        (await engine.run(now)).single.type,
        NotificationType.taskReminder,
      );
    },
  );

  test('reminders on completed tasks are skipped but consumed', () async {
    await tasks.save(task('t1', status: TaskStatus.completed));
    await reminders.save(
      reminder('r', at: now, target: ReminderTarget.task, targetId: 't1'),
    );
    final created = await engine.run(now);
    expect(
      created.where((n) => n.type == NotificationType.taskReminder),
      isEmpty,
    );
    expect((await reminders.getById('r'))!.isFinished, isTrue);
  });

  test('preferences switch kinds off, or everything', () async {
    await tasks.saveAll([
      task('late', due: today.subtract(const Duration(days: 1))),
      task('soon', due: today),
    ]);
    await reminders.save(reminder('r', at: now));

    prefs = const NotificationPreferences(enabled: false);
    expect(await engine.run(now), isEmpty);

    prefs = const NotificationPreferences(
      reminders: false,
      upcomingTasks: false,
    );
    expect(keys(await engine.run(now)), [
      'overdueTask:late:2026-09-29',
      NotificationEngine.welcomeKey,
    ]);
    expect(
      (await reminders.getById('r'))!.lastFiredAt,
      isNull,
      reason: 'turning reminders back on still delivers it',
    );
  });

  test('new notifications go to every channel; failures are ignored', () async {
    await tasks.save(task('soon', due: today));
    await engine.run(now);
    expect(channel.batches, hasLength(1));
    expect(channel.batches.single, hasLength(2));

    await engine.run(now);
    expect(channel.batches, hasLength(1), reason: 'nothing new, no delivery');
  });

  test('dismissed alerts stay away, and are purged after 60 days', () async {
    await tasks.save(
      task('late', due: today.subtract(const Duration(days: 1))),
    );
    await engine.run(now);
    final service = NotificationService(notifications, clock: () => now);
    await service.dismissAll();

    expect(await engine.run(now), isEmpty, reason: 'not recreated');

    final muchLater = now.add(const Duration(days: 61));
    await engine.run(muchLater);
    final remaining = await notifications.getAll();
    expect(
      remaining.map((n) => n.key),
      containsAll([NotificationEngine.welcomeKey]),
      reason: 'the welcome is kept so it never comes back',
    );
  });
}
