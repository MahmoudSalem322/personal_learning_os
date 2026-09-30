import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/backup/data/local_backup_store.dart';
import 'package:personal_learning_os/features/backup/domain/backup_codec.dart';
import 'package:personal_learning_os/features/backup/domain/backup_service.dart';
import 'package:personal_learning_os/features/backup/domain/backup_snapshot.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:sembast/sembast_memory.dart';

final _t0 = DateTime.utc(2026, 9, 1);
final _now = DateTime.utc(2026, 9, 30, 12);

Category category(String id, {String name = 'Flutter', DateTime? updated}) =>
    Category(
      id: id,
      name: name,
      icon: 'code',
      primaryColor: 1,
      secondaryColor: 2,
      createdAt: _t0,
      updatedAt: updated ?? _t0,
    );

Resource resource(
  String id, {
  String title = 'Docs',
  String? categoryId,
  DateTime? updated,
}) => Resource(
  id: id,
  title: title,
  type: ResourceType.documentation,
  categoryId: categoryId,
  tags: const ['flutter'],
  progress: 40,
  isFavorite: true,
  createdAt: _t0,
  updatedAt: updated ?? _t0,
);

/// A snapshot with one of everything, linked together.
BackupSnapshot fullSnapshot() => BackupSnapshot(
  settings: const AppSettings(
    themePreference: ThemePreference.dark,
    language: AppLanguage.arabic,
  ),
  categories: [category('c1')],
  resources: [resource('r1', categoryId: 'c1')],
  notes: [
    Note(
      id: 'n1',
      title: 'Note',
      content: '# Hi',
      categoryId: 'c1',
      resourceId: 'r1',
      tags: const ['x'],
      isFavorite: true,
      createdAt: _t0,
      updatedAt: _t0,
    ),
  ],
  tasks: [
    Task(
      id: 't1',
      title: 'Task',
      categoryId: 'c1',
      resourceId: 'r1',
      dueDate: DateTime(2026, 10, 2),
      priority: TaskPriority.high,
      isFavorite: true,
      createdAt: _t0,
      updatedAt: _t0,
    ),
  ],
  reminders: [
    Reminder(
      id: 'rem1',
      target: ReminderTarget.task,
      targetId: 't1',
      remindAt: DateTime.utc(2026, 10, 1, 8),
      repeat: ReminderRepeat.daily,
      createdAt: _t0,
      updatedAt: _t0,
    ),
  ],
  notifications: [
    AppNotification(
      id: 'not1',
      type: NotificationType.overdueTask,
      key: 'overdueTask:t1:2026-09-29',
      subject: 'Task',
      target: NotificationTarget.task,
      targetId: 't1',
      dueDate: DateTime(2026, 9, 29),
      createdAt: _t0,
      readAt: _t0,
    ),
  ],
);

Map<String, Object?> fileJson(BackupSnapshot s) =>
    jsonDecode(BackupCodec.encode(s, now: _now)) as Map<String, Object?>;

void main() {
  test('every store is part of the backup', () {
    // A new store must be added to BackupSnapshot, BackupCodec and
    // LocalBackupStore; update this count when you do.
    expect(AppStores.all, hasLength(7));
    expect(BackupCollection.values, hasLength(AppStores.all.length - 1));
  });

  group('codec', () {
    test('round trip keeps everything', () {
      final original = fullSnapshot();
      final decoded = BackupCodec.decode(
        BackupCodec.encode(original, now: _now),
      );
      expect(decoded.settings, original.settings);
      expect(decoded.categories, original.categories);
      expect(decoded.resources, original.resources);
      expect(decoded.notes, original.notes);
      expect(decoded.tasks, original.tasks);
      expect(decoded.reminders, original.reminders);
      expect(decoded.notifications, original.notifications);
      expect(decoded.exportedAt, _now);
    });

    BackupProblem problemOf(String text) {
      try {
        BackupCodec.decode(text);
      } on BackupFormatException catch (e) {
        return e.problem;
      }
      fail('accepted: $text');
    }

    test('rejects files that are not backups', () {
      expect(problemOf('not json {'), BackupProblem.notJson);
      expect(problemOf('[1, 2]'), BackupProblem.notBackup);
      expect(
        problemOf('{"app": "other", "format": 1}'),
        BackupProblem.notBackup,
      );
      expect(
        problemOf('{"app": "learning-os", "format": "1"}'),
        BackupProblem.notBackup,
      );
      expect(
        problemOf('{"app": "learning-os", "format": 1, "tasks": {}}'),
        BackupProblem.notBackup,
      );
      expect(
        problemOf('{"app": "learning-os", "format": 99}'),
        BackupProblem.newerVersion,
      );
    });

    test('rejects damaged records and says where', () {
      final json = fileJson(fullSnapshot());
      (json['tasks']! as List).addAll([
        {'id': 'broken'},
        'not a record',
      ]);
      try {
        BackupCodec.decode(jsonEncode(json));
        fail('accepted damaged tasks');
      } on BackupFormatException catch (e) {
        expect(e.problem, BackupProblem.invalidRecords);
        expect(e.collection, BackupCollection.tasks);
        expect(e.count, 2);
      }
    });

    test('rejects duplicate ids', () {
      final json = fileJson(fullSnapshot());
      final notes = json['notes']! as List;
      notes.add(notes.first);
      expect(
        () => BackupCodec.decode(jsonEncode(json)),
        throwsA(
          isA<BackupFormatException>()
              .having((e) => e.problem, 'problem', BackupProblem.duplicateIds)
              .having((e) => e.collection, 'in', BackupCollection.notes),
        ),
      );
    });

    test('missing collections read as empty; unknown fields are ignored', () {
      final decoded = BackupCodec.decode(
        jsonEncode({
          'app': 'learning-os',
          'format': 1,
          'future': true,
          'categories': [category('c1').toJson()..['extra'] = 1],
        }),
      );
      expect(decoded.categories.single.id, 'c1');
      expect(decoded.tasks, isEmpty);
      expect(decoded.settings, AppSettings.defaults);
    });

    test('links to missing items are cleared; orphan reminders dropped', () {
      final snapshot = fullSnapshot().copyWith(categories: [], resources: []);
      final json = fileJson(snapshot);
      final decoded = BackupCodec.decode(jsonEncode(json));
      expect(decoded.notes.single.categoryId, isNull);
      expect(decoded.notes.single.resourceId, isNull);
      expect(decoded.tasks.single.categoryId, isNull);

      final withoutTasks = BackupCodec.decode(
        jsonEncode(fileJson(fullSnapshot().copyWith(tasks: []))),
      );
      expect(withoutTasks.reminders, isEmpty);
    });
  });

  group('merge', () {
    test('adds new records, newer versions win, ours win ties', () {
      final ours = BackupSnapshot(
        settings: const AppSettings(themePreference: ThemePreference.light),
        categories: [
          category('same', name: 'Ours'),
          category('older', name: 'Ours', updated: DateTime.utc(2026, 9, 5)),
          category('mine'),
        ],
      );
      final theirs = BackupSnapshot(
        settings: const AppSettings(themePreference: ThemePreference.dark),
        categories: [
          category('same', name: 'Theirs'),
          category('older', name: 'Theirs', updated: DateTime.utc(2026, 9, 9)),
          category('new'),
        ],
      );
      final merged = ours.mergedWith(theirs);
      final names = {for (final c in merged.categories) c.id: c.name};
      expect(names, {
        'same': 'Ours',
        'older': 'Theirs',
        'mine': 'Flutter',
        'new': 'Flutter',
      });
      expect(merged.settings.themePreference, ThemePreference.light);
    });

    test('notifications for the same alert are not duplicated', () {
      final ours = fullSnapshot();
      final theirs = BackupSnapshot(
        notifications: [
          AppNotification(
            id: 'other-id',
            type: NotificationType.overdueTask,
            key: ours.notifications.single.key,
            createdAt: _t0,
          ),
        ],
      );
      expect(ours.mergedWith(theirs).notifications, hasLength(1));
    });
  });

  group('service', () {
    late Database db;
    late LocalBackupStore store;
    late BackupService service;

    setUp(() async {
      db = await AppDatabase.open(newDatabaseFactoryMemory());
      store = LocalBackupStore(db);
      service = BackupService(store, clock: () => _now);
    });

    tearDown(() => db.close());

    test(
      'export then replace into an empty database restores everything',
      () async {
        await store.replaceAll(fullSnapshot());
        final json = await service.exportJson();

        final otherDb = await AppDatabase.open(newDatabaseFactoryMemory());
        addTearDown(otherDb.close);
        final other = BackupService(
          LocalBackupStore(otherDb),
          clock: () => _now,
        );
        await other.import(other.parse(json), ImportMode.replace);

        final restored = await LocalBackupStore(otherDb).read();
        final original = fullSnapshot();
        expect(restored.settings, original.settings);
        expect(restored.tasks, original.tasks);
        expect(restored.reminders, original.reminders);
        expect(restored.notes, original.notes);
        expect(service.fileName(), 'qabas-backup-2026-09-30.json');
      },
    );

    test('replace can be undone', () async {
      await store.replaceAll(fullSnapshot());
      final previous = await service.import(
        BackupSnapshot(categories: [category('only')]),
        ImportMode.replace,
      );
      expect((await store.read()).categories.single.id, 'only');
      expect((await store.read()).tasks, isEmpty);

      await service.restore(previous);
      expect((await store.read()).tasks.single.id, 't1');
    });

    test('merge keeps existing data', () async {
      await store.replaceAll(fullSnapshot());
      await service.import(
        BackupSnapshot(resources: [resource('r2', title: 'New')]),
        ImportMode.merge,
      );
      final data = await store.read();
      expect(data.resources.map((r) => r.id), containsAll(['r1', 'r2']));
      expect(data.tasks, hasLength(1));
      expect(data.settings.language, AppLanguage.arabic);
    });

    test('clear all keeps settings and can be undone', () async {
      await store.replaceAll(fullSnapshot());
      final previous = await service.clearAll();
      final cleared = await store.read();
      expect(cleared.isEmpty, isTrue);
      expect(cleared.settings.themePreference, ThemePreference.dark);

      await service.restore(previous);
      expect((await store.read()).isEmpty, isFalse);
    });

    test('an invalid file changes nothing', () async {
      await store.replaceAll(fullSnapshot());
      expect(
        () =>
            service.parse('{"app": "learning-os", "format": 1, "notes": [1]}'),
        throwsA(isA<BackupFormatException>()),
      );
      expect((await store.read()).notes, hasLength(1));
    });
  });
}
