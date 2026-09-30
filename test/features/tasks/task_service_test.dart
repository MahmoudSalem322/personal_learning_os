import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/utils/id_generator.dart';
import 'package:personal_learning_os/features/tasks/data/local_task_repository.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/features/tasks/domain/task_draft.dart';
import 'package:personal_learning_os/features/tasks/domain/task_service.dart';
import 'package:sembast/sembast_memory.dart';

class _SequentialIds extends IdGenerator {
  int _next = 0;

  @override
  String next() => 'id-${_next++}';
}

TaskDraft draft(String title, {DateTime? dueDate}) =>
    TaskDraft(title: title, dueDate: dueDate);

void main() {
  late Database db;
  late LocalTaskRepository repository;
  late TaskService service;
  late DateTime now;

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    repository = LocalTaskRepository(db);
    now = DateTime.utc(2026, 9, 28, 9);
    service = TaskService(repository, ids: _SequentialIds(), clock: () => now);
  });

  tearDown(() => db.close());

  group('create and update', () {
    test('persists a normalized task with id and timestamps', () async {
      final created = await service.create(
        draft('  Learn   Riverpod  ', dueDate: DateTime(2026, 9, 30)),
      );

      expect(created.id, 'id-0');
      expect(created.title, 'Learn Riverpod');
      expect(created.status, TaskStatus.todo);
      expect(created.priority, TaskPriority.medium);
      expect(created.dueDate, DateTime(2026, 9, 30));
      expect(created.completedAt, isNull);
      expect(created.createdAt, now);
      expect(created.updatedAt, now);
      expect(await repository.getById('id-0'), created);
    });

    test('rejects an empty title', () async {
      await expectLater(
        service.create(draft('   ')),
        throwsA(
          isA<TaskValidationException>().having((e) => e.errors, 'errors', {
            TaskFieldError.titleRequired,
          }),
        ),
      );
      expect(await repository.getAll(), isEmpty);
    });

    test('update keeps createdAt and bumps updatedAt', () async {
      final created = await service.create(draft('Read docs'));
      now = now.add(const Duration(hours: 2));

      final updated = await service.update(
        created.id,
        const TaskDraft(
          title: 'Read docs',
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
        ),
      );

      expect(updated.priority, TaskPriority.high);
      expect(updated.status, TaskStatus.inProgress);
      expect(updated.createdAt, created.createdAt);
      expect(updated.updatedAt, now);
    });

    test('update keeps completedAt when staying completed', () async {
      final completedAt = DateTime.utc(2026, 9, 1, 12);
      final created = await service.create(
        const TaskDraft(title: 'Done before', status: TaskStatus.completed),
      );
      final withStamp = created.copyWith(completedAt: completedAt);
      await repository.save(withStamp);

      now = now.add(const Duration(days: 1));
      final updated = await service.update(
        withStamp.id,
        const TaskDraft(
          title: 'Done before',
          status: TaskStatus.completed,
          priority: TaskPriority.low,
        ),
      );

      expect(updated.completedAt, completedAt);
    });
  });

  group('status transitions', () {
    test('completing stamps completedAt and reopens clears it', () async {
      final created = await service.create(draft('Practice'));

      final done = await service.setStatus(created.id, TaskStatus.completed);
      expect(done.status, TaskStatus.completed);
      expect(done.completedAt, now);

      now = now.add(const Duration(hours: 3));
      final reopened = await service.setStatus(created.id, TaskStatus.todo);
      expect(reopened.status, TaskStatus.todo);
      expect(reopened.completedAt, isNull);
      expect(reopened.updatedAt, now);
    });

    test('toggleCompleted returns to todo', () async {
      final created = await service.create(draft('Practice'));
      final done = await service.toggleCompleted(created.id);
      expect(done.isCompleted, isTrue);
      final undone = await service.toggleCompleted(created.id);
      expect(undone.status, TaskStatus.todo);
      expect(undone.completedAt, isNull);
    });

    test('setStatus to the same value does not touch updatedAt', () async {
      final created = await service.create(draft('Practice'));
      final same = await service.setStatus(created.id, TaskStatus.todo);
      expect(same.updatedAt, created.updatedAt);
    });
  });

  group('priority and due date', () {
    test('setPriority clamps nothing and persists', () async {
      final created = await service.create(draft('Practice'));
      final updated = await service.setPriority(created.id, TaskPriority.high);
      expect(updated.priority, TaskPriority.high);
      expect(await repository.getById(created.id), updated);
    });

    test('setDueDate normalizes to midnight and can clear', () async {
      final created = await service.create(draft('Practice'));
      final updated = await service.setDueDate(
        created.id,
        DateTime(2026, 10, 5, 15, 30),
      );
      expect(updated.dueDate, DateTime(2026, 10, 5));

      final cleared = await service.setDueDate(created.id, null);
      expect(cleared.dueDate, isNull);
    });
  });

  group('overdue and views', () {
    test('isOverdue is true only for open tasks past their day', () {
      final yesterday = DateTime(2026, 9, 27);
      final today = DateTime(2026, 9, 28);
      final now = DateTime(2026, 9, 28, 12);

      Task task(DateTime? due, {TaskStatus status = TaskStatus.todo}) => Task(
        id: 't',
        title: 't',
        status: status,
        dueDate: due,
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      expect(task(yesterday).isOverdue(now), isTrue);
      expect(task(today).isOverdue(now), isFalse);
      expect(
        task(yesterday, status: TaskStatus.completed).isOverdue(now),
        isFalse,
      );
      expect(task(null).isOverdue(now), isFalse);
    });
  });

  group('delete and restore', () {
    test('delete returns the task and restore brings it back', () async {
      final created = await service.create(draft('Practice'));
      final deleted = await service.delete(created.id);

      expect(deleted.title, 'Practice');
      expect(await repository.getById(created.id), isNull);

      await service.restore(deleted);
      expect(await repository.getById(created.id), deleted);
    });

    test('deleting an unknown id throws NotFoundException', () async {
      await expectLater(
        service.delete('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('links survive category/resource deletes', () {
    test('clearCategory and clearResource unlink without deleting', () async {
      final created = await service.create(const TaskDraft(title: 'Linked'));
      final task = created.copyWith(
        categoryId: 'cat-1',
        resourceId: 'res-1',
        updatedAt: now,
      );
      await repository.save(task);

      final changedCategory = await repository.clearCategory('cat-1');
      expect(changedCategory, [task.id]);
      expect((await repository.getById(task.id))!.categoryId, isNull);

      final changedResource = await repository.clearResource('res-1');
      expect(changedResource, [task.id]);
      final after = await repository.getById(task.id);
      expect(after!.resourceId, isNull);
      expect(after.title, 'Linked');
    });
  });

  group('persistence round trip', () {
    test('toJson/fromJson keeps every field', () {
      final task = Task(
        id: 't1',
        title: 'Task',
        description: 'Desc',
        categoryId: 'c',
        resourceId: 'r',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        dueDate: DateTime(2026, 10, 1),
        completedAt: DateTime(2026, 9, 20),
        isFavorite: true,
        tags: const ['flutter'],
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 2),
      );

      final parsed = Task.fromJson(task.toJson());

      expect(parsed.id, task.id);
      expect(parsed.title, task.title);
      expect(parsed.description, task.description);
      expect(parsed.categoryId, task.categoryId);
      expect(parsed.resourceId, task.resourceId);
      expect(parsed.priority, task.priority);
      expect(parsed.status, task.status);
      expect(parsed.dueDate, task.dueDate);
      expect(parsed.completedAt!.isAtSameMomentAs(task.completedAt!), isTrue);
      expect(parsed.isFavorite, task.isFavorite);
      expect(parsed.tags, task.tags);
      expect(parsed.createdAt, task.createdAt);
      expect(parsed.updatedAt, task.updatedAt);
    });

    test('fromJson tolerates unknown enum values and missing optionals', () {
      final parsed = Task.fromJson({
        'id': 't2',
        'title': 'Legacy',
        'priority': 'urgent',
        'status': 'archived',
        'createdAt': '2026-09-01T00:00:00.000Z',
        'updatedAt': '2026-09-02T00:00:00.000Z',
      });

      expect(parsed.priority, TaskPriority.medium);
      expect(parsed.status, TaskStatus.todo);
      expect(parsed.completedAt, isNull);
      expect(parsed.dueDate, isNull);
    });
  });

  group('review fixes', () {
    test('completing through the form stamps the current time', () async {
      final created = await service.create(draft('Read docs'));
      now = now.add(const Duration(hours: 3));
      final done = await service.update(
        created.id,
        TaskDraft(title: created.title, status: TaskStatus.completed),
      );
      expect(done.completedAt, now);
    });

    test('favorite toggles and survives edits', () async {
      final created = await service.create(draft('Star me'));
      final starred = await service.setFavorite(created.id, favorite: true);
      expect(starred.isFavorite, isTrue);

      final edited = await service.update(
        created.id,
        const TaskDraft(title: 'Renamed'),
      );
      expect(edited.isFavorite, isTrue);
      expect((await repository.getById(created.id))!.isFavorite, isTrue);
    });

    test('due dates are stored as calendar days', () async {
      final created = await service.create(
        draft('Due', dueDate: DateTime(2026, 10, 1, 18, 30)),
      );
      expect(created.toJson()['dueDate'], '2026-10-01');
      final stored = await repository.getById(created.id);
      expect(stored!.dueDate, DateTime(2026, 10, 1));
    });

    test('older UTC timestamps keep their local day', () {
      final localMidnight = DateTime(2026, 10, 1);
      final parsed = Task.fromJson({
        'id': 'legacy',
        'title': 'Legacy',
        'dueDate': localMidnight.toUtc().toIso8601String(),
        'createdAt': '2026-09-01T00:00:00.000Z',
        'updatedAt': '2026-09-01T00:00:00.000Z',
      });
      expect(parsed.dueDate, localMidnight);
    });
  });
}
