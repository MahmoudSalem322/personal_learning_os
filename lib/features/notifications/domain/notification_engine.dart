import 'dart:developer' as developer;

import '../../../core/utils/id_generator.dart';
import '../../reminders/domain/reminder.dart';
import '../../reminders/domain/reminder_repository.dart';
import '../../resources/domain/resource_repository.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_repository.dart';
import 'app_notification.dart';
import 'notification_channel.dart';
import 'notification_preferences.dart';
import 'notification_repository.dart';

/// Turns the user's data into notifications. Runs offline, whenever the app
/// is open ([run] is called on start, every minute and after changes).
///
/// Rules:
/// - A due reminder creates one notification per occurrence. One-off
///   reminders then finish; repeating ones move to their next occurrence
///   (occurrences missed while the app was closed fire once, not N times).
///   Reminders whose task/resource no longer exists wait (Undo brings the
///   item back); reminders on completed tasks are skipped.
/// - An open task due today or tomorrow gets one "upcoming" notification per
///   due date; once past its due date it gets one "overdue" notification.
/// - A welcome notification is created once.
/// - Dismissed notifications are deleted after [retention], so their keys
///   can't pile up forever.
class NotificationEngine {
  NotificationEngine({
    required this._notifications,
    required this._reminders,
    required this._tasks,
    required this._resources,
    required this._preferences,
    this._channels = const [],
    IdGenerator? ids,
  }) : _ids = ids ?? IdGenerator();

  static const Duration retention = Duration(days: 60);
  static const String welcomeKey = 'system:welcome';

  final NotificationRepository _notifications;
  final ReminderRepository _reminders;
  final TaskRepository _tasks;
  final ResourceRepository _resources;
  final NotificationPreferences Function() _preferences;
  final List<NotificationChannel> _channels;
  final IdGenerator _ids;

  /// Creates what's due at [now] and returns the new notifications.
  Future<List<AppNotification>> run(DateTime now) async {
    final prefs = _preferences();
    final existing = await _notifications.getAll();
    await _purge(existing, now);
    if (!prefs.enabled) return const [];

    final keys = {for (final n in existing) n.key};
    final created = <AppNotification>[];
    void add(AppNotification n) {
      if (keys.add(n.key)) created.add(n);
    }

    if (!keys.contains(welcomeKey)) {
      add(
        AppNotification(
          id: _ids.next(),
          type: NotificationType.system,
          key: welcomeKey,
          notice: SystemNotice.welcome,
          createdAt: now,
        ),
      );
    }

    final tasks = await _tasks.getAll();
    if (prefs.allowsReminders) {
      await _fireReminders(now, {for (final t in tasks) t.id: t}, add);
    }
    for (final task in tasks) {
      final alert = _taskAlert(task, now, prefs);
      if (alert != null) add(alert);
    }

    if (created.isNotEmpty) {
      await _notifications.saveAll(created);
      for (final channel in _channels) {
        try {
          await channel.deliver(created);
        } catch (error, stackTrace) {
          developer.log(
            'Notification channel failed',
            name: 'notifications',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }
    return created;
  }

  Future<void> _fireReminders(
    DateTime now,
    Map<String, Task> tasks,
    void Function(AppNotification) add,
  ) async {
    final changed = <Reminder>[];
    for (final r in await _reminders.getAll()) {
      if (!r.isDue(now)) continue;

      String subject;
      NotificationTarget target;
      var notify = true;
      switch (r.target) {
        case ReminderTarget.task:
          final task = tasks[r.targetId];
          if (task == null) continue; // Deleted: wait for a possible Undo.
          subject = task.title;
          target = NotificationTarget.task;
          notify = !task.isCompleted;
        case ReminderTarget.resource:
          final resource = await _resources.getById(r.targetId ?? '');
          if (resource == null) continue;
          subject = resource.title;
          target = NotificationTarget.resource;
        case ReminderTarget.session:
          subject = r.title;
          target = NotificationTarget.none;
      }

      if (notify) {
        add(
          AppNotification(
            id: _ids.next(),
            type: r.target == ReminderTarget.task
                ? NotificationType.taskReminder
                : NotificationType.learningReminder,
            key: 'reminder:${r.id}:${r.remindAt.toUtc().toIso8601String()}',
            subject: subject,
            note: r.target == ReminderTarget.session ? '' : r.title,
            target: target,
            targetId: r.targetId,
            createdAt: now,
          ),
        );
      }
      changed.add(
        r.copyWith(
          lastFiredAt: now,
          remindAt: r.isRepeating ? r.nextAfter(now) : r.remindAt,
        ),
      );
    }
    if (changed.isNotEmpty) await _reminders.saveAll(changed);
  }

  AppNotification? _taskAlert(
    Task task,
    DateTime now,
    NotificationPreferences prefs,
  ) {
    final due = task.dueDate;
    if (due == null || task.isCompleted) return null;
    final day = AppNotification.formatDay(due);

    NotificationType type;
    if (task.isOverdue(now)) {
      if (!prefs.allowsOverdue) return null;
      type = NotificationType.overdueTask;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final days = DateTime(
        due.year,
        due.month,
        due.day,
      ).difference(today).inDays;
      if (days > 1 || !prefs.allowsUpcoming) return null;
      type = NotificationType.upcomingTask;
    }
    return AppNotification(
      id: _ids.next(),
      type: type,
      key: '${type.name}:${task.id}:$day',
      subject: task.title,
      target: NotificationTarget.task,
      targetId: task.id,
      dueDate: due,
      createdAt: now,
    );
  }

  Future<void> _purge(List<AppNotification> all, DateTime now) async {
    final old = [
      for (final n in all)
        if (n.dismissedAt != null &&
            n.key != welcomeKey &&
            now.difference(n.dismissedAt!) > retention)
          n.id,
    ];
    if (old.isNotEmpty) await _notifications.deleteAll(old);
  }
}
