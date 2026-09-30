import 'package:flutter/foundation.dart' show immutable;

import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../notifications/domain/app_notification.dart';
import '../../reminders/domain/reminder.dart';
import '../../resources/domain/resource.dart';
import '../../settings/domain/app_settings.dart';
import '../../tasks/domain/task.dart';

/// The kinds of records a backup holds, in file order.
enum BackupCollection {
  categories,
  resources,
  notes,
  tasks,
  reminders,
  notifications,
}

/// Everything the user has, at one moment: what a backup file contains and
/// what a restore writes back.
///
/// Tags, progress and favorites live inside the records (resource/note/task
/// fields), so they travel with them.
@immutable
class BackupSnapshot {
  const BackupSnapshot({
    this.settings = AppSettings.defaults,
    this.categories = const [],
    this.resources = const [],
    this.notes = const [],
    this.tasks = const [],
    this.reminders = const [],
    this.notifications = const [],
    this.exportedAt,
  });

  static const BackupSnapshot empty = BackupSnapshot();

  final AppSettings settings;
  final List<Category> categories;
  final List<Resource> resources;
  final List<Note> notes;
  final List<Task> tasks;
  final List<Reminder> reminders;
  final List<AppNotification> notifications;

  /// When the file was created; `null` for snapshots taken in the app.
  final DateTime? exportedAt;

  int countOf(BackupCollection collection) => switch (collection) {
    BackupCollection.categories => categories.length,
    BackupCollection.resources => resources.length,
    BackupCollection.notes => notes.length,
    BackupCollection.tasks => tasks.length,
    BackupCollection.reminders => reminders.length,
    BackupCollection.notifications => notifications.length,
  };

  /// No user data (settings don't count).
  bool get isEmpty => BackupCollection.values.every((c) => countOf(c) == 0);

  BackupSnapshot copyWith({
    AppSettings? settings,
    List<Category>? categories,
    List<Resource>? resources,
    List<Note>? notes,
    List<Task>? tasks,
    List<Reminder>? reminders,
    List<AppNotification>? notifications,
  }) {
    return BackupSnapshot(
      settings: settings ?? this.settings,
      categories: categories ?? this.categories,
      resources: resources ?? this.resources,
      notes: notes ?? this.notes,
      tasks: tasks ?? this.tasks,
      reminders: reminders ?? this.reminders,
      notifications: notifications ?? this.notifications,
      exportedAt: exportedAt,
    );
  }

  /// Clears links to categories/resources that aren't in this snapshot and
  /// drops reminders whose task/resource is missing, so a restore never
  /// leaves dangling references.
  BackupSnapshot withValidLinks() {
    final categoryIds = {for (final c in categories) c.id};
    final resourceIds = {for (final r in resources) r.id};
    final taskIds = {for (final t in tasks) t.id};
    String? keep(String? id, Set<String> valid) =>
        id != null && valid.contains(id) ? id : null;

    return copyWith(
      resources: [
        for (final r in resources)
          r.categoryId == keep(r.categoryId, categoryIds)
              ? r
              : r.copyWith(categoryId: null),
      ],
      notes: [
        for (final n in notes)
          n.categoryId == keep(n.categoryId, categoryIds) &&
                  n.resourceId == keep(n.resourceId, resourceIds)
              ? n
              : n.copyWith(
                  categoryId: keep(n.categoryId, categoryIds),
                  resourceId: keep(n.resourceId, resourceIds),
                ),
      ],
      tasks: [
        for (final t in tasks)
          t.categoryId == keep(t.categoryId, categoryIds) &&
                  t.resourceId == keep(t.resourceId, resourceIds)
              ? t
              : t.copyWith(
                  categoryId: keep(t.categoryId, categoryIds),
                  resourceId: keep(t.resourceId, resourceIds),
                ),
      ],
      reminders: [
        for (final r in reminders)
          if (switch (r.target) {
            ReminderTarget.task => taskIds.contains(r.targetId),
            ReminderTarget.resource => resourceIds.contains(r.targetId),
            ReminderTarget.session => true,
          })
            r,
      ],
    );
  }

  /// [incoming] merged into this snapshot: records are matched by id and
  /// the most recently updated version wins (ties keep ours). Notifications
  /// already present (same id or same alert) are kept as they are. Settings
  /// stay ours.
  BackupSnapshot mergedWith(BackupSnapshot incoming) {
    List<T> merge<T>(
      List<T> ours,
      List<T> theirs,
      String Function(T) idOf,
      DateTime Function(T) updatedAt,
    ) {
      final byId = {for (final item in ours) idOf(item): item};
      for (final item in theirs) {
        final current = byId[idOf(item)];
        if (current == null || updatedAt(item).isAfter(updatedAt(current))) {
          byId[idOf(item)] = item;
        }
      }
      return byId.values.toList();
    }

    final notificationIds = {for (final n in notifications) n.id};
    final notificationKeys = {for (final n in notifications) n.key};
    return copyWith(
      categories: merge(
        categories,
        incoming.categories,
        (c) => c.id,
        (c) => c.updatedAt,
      ),
      resources: merge(
        resources,
        incoming.resources,
        (r) => r.id,
        (r) => r.updatedAt,
      ),
      notes: merge(notes, incoming.notes, (n) => n.id, (n) => n.updatedAt),
      tasks: merge(tasks, incoming.tasks, (t) => t.id, (t) => t.updatedAt),
      reminders: merge(
        reminders,
        incoming.reminders,
        (r) => r.id,
        (r) => r.updatedAt,
      ),
      notifications: [
        ...notifications,
        for (final n in incoming.notifications)
          if (!notificationIds.contains(n.id) &&
              !notificationKeys.contains(n.key))
            n,
      ],
    ).withValidLinks();
  }
}
