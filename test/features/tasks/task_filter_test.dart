import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/features/tasks/domain/task_filter.dart';

Task task({
  required String id,
  String title = 'Task',
  String description = '',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  String? categoryId,
  List<String> tags = const [],
  DateTime? createdAt,
}) {
  final now = DateTime(2026, 9, 28, 10);
  return Task(
    id: id,
    title: title,
    description: description,
    status: status,
    priority: priority,
    dueDate: dueDate,
    categoryId: categoryId,
    tags: tags,
    createdAt: createdAt ?? now.subtract(const Duration(days: 1)),
    updatedAt: now,
  );
}

void main() {
  final now = DateTime(2026, 9, 28, 10); // Sep 28, 2026, 10:00
  final today = DateTime(2026, 9, 28);
  final tomorrow = DateTime(2026, 9, 29);
  final lastWeek = DateTime(2026, 9, 21);

  group('views', () {
    test('all shows everything', () {
      const filter = TaskFilter();
      final tasks = [
        task(id: 'a', status: TaskStatus.completed),
        task(id: 'b', dueDate: lastWeek),
      ];
      // Open tasks first; completed ones sink to the bottom.
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['b', 'a']);
    });

    test('today shows tasks due today and not completed', () {
      const filter = TaskFilter(view: TaskView.today);
      final tasks = [
        task(id: 'due-today', dueDate: today),
        task(
          id: 'completed-today',
          dueDate: today,
          status: TaskStatus.completed,
        ),
        task(id: 'due-tomorrow', dueDate: tomorrow),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['due-today']);
    });

    test('upcoming shows open tasks due after now', () {
      const filter = TaskFilter(view: TaskView.upcoming);
      final tasks = [
        task(id: 'past', dueDate: lastWeek),
        task(id: 'today', dueDate: today),
        task(id: 'tomorrow', dueDate: tomorrow),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['tomorrow']);
    });

    test('overdue shows open tasks whose day has passed', () {
      const filter = TaskFilter(view: TaskView.overdue);
      final tasks = [
        task(id: 'overdue', dueDate: lastWeek),
        task(id: 'today', dueDate: today),
        task(id: 'done', dueDate: lastWeek, status: TaskStatus.completed),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['overdue']);
    });

    test('completed shows only completed tasks', () {
      const filter = TaskFilter(view: TaskView.completed);
      final tasks = [
        task(id: 'open'),
        task(id: 'done', status: TaskStatus.completed),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['done']);
    });
  });

  group('filters', () {
    test('status filter narrows independent of the view', () {
      const filter = TaskFilter(status: TaskStatus.inProgress);
      final tasks = [
        task(id: 'todo', status: TaskStatus.todo),
        task(id: 'wip', status: TaskStatus.inProgress),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['wip']);
    });

    test('priority filter matches exactly', () {
      const filter = TaskFilter(priority: TaskPriority.high);
      final tasks = [
        task(id: 'low', priority: TaskPriority.low),
        task(id: 'high', priority: TaskPriority.high),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['high']);
    });

    test('category filter supports uncategorized', () {
      const filter = TaskFilter(categoryId: TaskFilter.uncategorized);
      final tasks = [task(id: 'cat', categoryId: 'flutter'), task(id: 'none')];
      expect(filter.apply(tasks, now: now).map((t) => t.id), ['none']);
    });

    test('query matches title, description and tags', () {
      const filter = TaskFilter(query: 'riverpod');
      final tasks = [
        task(id: 'title', title: 'Learn Riverpod'),
        task(id: 'desc', description: 'State management with riverpod'),
        task(id: 'tag', tags: ['riverpod']),
        task(id: 'other', title: 'Git basics'),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), [
        'title',
        'desc',
        'tag',
      ]);
    });
  });

  group('sorting', () {
    test('dueDate puts undated tasks last', () {
      const filter = TaskFilter(sort: TaskSort.dueDate);
      final tasks = [
        task(id: 'none'),
        task(id: 'later', dueDate: tomorrow),
        task(id: 'sooner', dueDate: today),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), [
        'sooner',
        'later',
        'none',
      ]);
    });

    test('priority orders high, medium, low', () {
      const filter = TaskFilter(sort: TaskSort.priority);
      final tasks = [
        task(id: 'low', priority: TaskPriority.low),
        task(id: 'high', priority: TaskPriority.high),
        task(id: 'medium', priority: TaskPriority.medium),
      ];
      expect(filter.apply(tasks, now: now).map((t) => t.id), [
        'high',
        'medium',
        'low',
      ]);
    });
  });
}
