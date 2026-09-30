import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/categories/data/local_category_repository.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/notes/data/local_note_repository.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notifications/data/local_notification_repository.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/reminders/data/local_reminder_repository.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/sample_data/domain/sample_data_service.dart';
import 'package:personal_learning_os/features/sample_data/presentation/sample_catalog.dart';
import 'package:personal_learning_os/features/tasks/data/local_task_repository.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/l10n/app_localizations_en.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late LocalCategoryRepository categories;
  late LocalResourceRepository resources;
  late LocalNoteRepository notes;
  late LocalTaskRepository tasks;
  late LocalReminderRepository reminders;
  late LocalNotificationRepository notifications;
  late SampleDataService service;
  final now = DateTime.utc(2026, 9, 28);
  final l10n = AppLocalizationsEn();
  final sampleCats = sampleCategories(l10n, now);
  final sampleRes = sampleResources(l10n, now);
  final sampleNts = sampleNotes(l10n, now);
  final sampleTsks = sampleTasks(l10n, now);

  Future<int> loadAll() => service.load(
    categories: sampleCats,
    resources: sampleRes,
    notes: sampleNts,
    tasks: sampleTsks,
  );

  Category ownCategory(String id, String name) => Category(
    id: id,
    name: name,
    icon: 'folder',
    primaryColor: 0,
    secondaryColor: 0,
    createdAt: now,
    updatedAt: now,
  );

  Resource ownResource(String id, {String? categoryId}) => Resource(
    id: id,
    title: 'Mine',
    type: ResourceType.website,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    categories = LocalCategoryRepository(db);
    resources = LocalResourceRepository(db);
    notes = LocalNoteRepository(db);
    tasks = LocalTaskRepository(db);
    reminders = LocalReminderRepository(db);
    notifications = LocalNotificationRepository(db);
    service = SampleDataService(
      categories: categories,
      resources: resources,
      notes: notes,
      tasks: tasks,
      reminders: reminders,
      notifications: notifications,
    );
  });

  tearDown(() => db.close());

  test('catalog: four categories and resources linked to them', () {
    expect(sampleCats.map((c) => c.name), [
      'Flutter',
      'Dart',
      'UI/UX',
      'Git & GitHub',
    ]);
    final categoryIds = sampleCats.map((c) => c.id).toSet();
    expect(sampleRes, isNotEmpty);
    expect(sampleRes.every((r) => categoryIds.contains(r.categoryId)), isTrue);
    expect(
      [
        ...sampleCats.map((c) => c.id),
        ...sampleRes.map((r) => r.id),
      ].every(SampleDataService.isSampleId),
      isTrue,
    );
  });

  test('load adds everything once', () async {
    expect(
      await loadAll(),
      sampleCats.length +
          sampleRes.length +
          sampleNts.length +
          sampleTsks.length,
    );
    expect(await loadAll(), 0);
    expect(await categories.getAll(), hasLength(sampleCats.length));
    expect(await resources.getAll(), hasLength(sampleRes.length));
    expect(await tasks.getAll(), hasLength(sampleTsks.length));
  });

  test('skips categories whose name the user already uses', () async {
    await categories.save(ownCategory('mine', 'flutter'));
    await loadAll();

    final names = (await categories.getAll()).map((c) => c.name.toLowerCase());
    expect(names.where((n) => n == 'flutter'), hasLength(1));
    // Sample Flutter resources are still added, just without a category.
    final flutterDocs = await resources.getById('sample-resource-flutter-docs');
    expect(flutterDocs, isNotNull);
    expect(flutterDocs!.categoryId, isNull);
  });

  test('sample notes link to sample categories and resources', () {
    final resourceIds = sampleRes.map((r) => r.id).toSet();
    expect(sampleNts, isNotEmpty);
    expect(sampleNts.every((n) => resourceIds.contains(n.resourceId)), isTrue);
    expect(sampleNts.every((n) => n.content.isNotEmpty), isTrue);
  });

  test('sample tasks cover every view and link to sample data', () {
    final categoryIds = sampleCats.map((c) => c.id).toSet();
    final resourceIds = sampleRes.map((r) => r.id).toSet();
    expect(sampleTsks, isNotEmpty);
    expect(sampleTsks.every((t) => categoryIds.contains(t.categoryId)), isTrue);
    expect(
      sampleTsks
          .where((t) => t.resourceId != null)
          .every((t) => resourceIds.contains(t.resourceId)),
      isTrue,
    );
    expect(sampleTsks.any((t) => t.isCompleted), isTrue);
    expect(sampleTsks.any((t) => t.isOverdue(now)), isTrue);
    expect(sampleTsks.any((t) => !t.isCompleted && t.dueDate != null), isTrue);
  });

  test('remove keeps user notes and drops their sample links', () async {
    await loadAll();
    await notes.save(
      Note(
        id: 'my-note',
        title: 'Mine',
        categoryId: 'sample-category-flutter',
        resourceId: 'sample-resource-riverpod',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await service.remove();

    final remaining = await notes.getAll();
    expect(remaining.map((n) => n.id), ['my-note']);
    expect(remaining.single.categoryId, isNull);
    expect(remaining.single.resourceId, isNull);
  });

  test('remove deletes sample tasks and unlinks user tasks', () async {
    await loadAll();
    await tasks.save(
      Task(
        id: 'my-task',
        title: 'Mine',
        categoryId: 'sample-category-flutter',
        resourceId: 'sample-resource-riverpod',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await service.remove();

    final remaining = await tasks.getAll();
    expect(remaining.map((t) => t.id), ['my-task']);
    expect(remaining.single.categoryId, isNull);
    expect(remaining.single.resourceId, isNull);
  });

  test('remove deletes only sample data and keeps user resources', () async {
    await categories.save(ownCategory('mine', 'Algorithms'));
    await loadAll();
    // The user filed their own resource under a sample category.
    await resources.save(
      ownResource('my-resource', categoryId: 'sample-category-dart'),
    );

    await service.remove();

    expect((await categories.getAll()).map((c) => c.id), ['mine']);
    final remaining = await resources.getAll();
    expect(remaining.map((r) => r.id), ['my-resource']);
    expect(remaining.single.categoryId, isNull);
  });

  test('remove deletes reminders and notifications about samples', () async {
    await loadAll();
    Reminder reminder(String id, String? targetId) => Reminder(
      id: id,
      target: targetId == null ? ReminderTarget.session : ReminderTarget.task,
      targetId: targetId,
      title: 'Study',
      remindAt: now,
      createdAt: now,
      updatedAt: now,
    );
    await reminders.saveAll([
      reminder('on-sample', 'sample-task-learn-riverpod'),
      reminder('session', null),
    ]);
    AppNotification notification(String id, String? targetId) =>
        AppNotification(
          id: id,
          type: NotificationType.overdueTask,
          key: id,
          target: targetId == null
              ? NotificationTarget.none
              : NotificationTarget.task,
          targetId: targetId,
          createdAt: now,
        );
    await notifications.saveAll([
      notification('about-sample', 'sample-task-learn-riverpod'),
      notification('welcome', null),
    ]);

    await service.remove();

    expect((await reminders.getAll()).map((r) => r.id), ['session']);
    expect((await notifications.getAll()).map((n) => n.id), ['welcome']);
  });
}
