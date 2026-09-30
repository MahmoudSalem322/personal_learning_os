import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/notifications/data/local_notification_repository.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_preferences.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_service.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late LocalNotificationRepository repository;
  late NotificationService service;
  final now = DateTime.utc(2026, 9, 30, 10);

  AppNotification notification(String id) => AppNotification(
    id: id,
    type: NotificationType.upcomingTask,
    key: id,
    subject: 'Task',
    target: NotificationTarget.task,
    targetId: 't',
    dueDate: DateTime(2026, 10, 1),
    createdAt: now,
  );

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    repository = LocalNotificationRepository(db);
    service = NotificationService(repository, clock: () => now);
    await repository.saveAll([notification('a'), notification('b')]);
  });

  tearDown(() => db.close());

  test('read, unread and mark all read', () async {
    await service.setRead('a', read: true);
    expect((await repository.getById('a'))!.isRead, isTrue);
    await service.setRead('a', read: false);
    expect((await repository.getById('a'))!.isRead, isFalse);

    await service.markAllRead();
    expect((await repository.getAll()).every((n) => n.isRead), isTrue);
  });

  test('dismiss and dismiss all can be undone', () async {
    final one = await service.dismiss('a');
    expect((await repository.getById('a'))!.isDismissed, isTrue);
    await service.restore([one]);
    expect((await repository.getById('a'))!.isDismissed, isFalse);

    final all = await service.dismissAll();
    expect(all, hasLength(2));
    expect((await repository.getAll()).every((n) => n.isDismissed), isTrue);
    await service.restore(all);
    expect((await repository.getAll()).any((n) => n.isDismissed), isFalse);
  });

  test('notifications survive a JSON round trip', () {
    final n = notification('x').copyWith(readAt: now);
    expect(AppNotification.fromJson(n.toJson()), n);
  });

  test('preferences are stored with the settings and default to on', () {
    const settings = AppSettings(
      notifications: NotificationPreferences(overdueTasks: false),
    );
    final restored = AppSettings.fromJson(settings.toJson());
    expect(restored.notifications.overdueTasks, isFalse);
    expect(restored.notifications.upcomingTasks, isTrue);
    expect(
      AppSettings.fromJson(const {}).notifications,
      NotificationPreferences.defaults,
      reason: 'settings saved before this phase',
    );
  });
}
