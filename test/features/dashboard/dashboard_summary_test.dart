import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/dashboard/domain/dashboard_summary.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/resources/domain/learning_progress.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';

final _t0 = DateTime(2026, 9, 1);

Resource resource(
  String id, {
  int progress = 0,
  String? categoryId,
  bool favorite = false,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? lastOpenedAt,
}) => Resource(
  id: id,
  title: id,
  type: ResourceType.website,
  progress: progress,
  categoryId: categoryId,
  isFavorite: favorite,
  createdAt: createdAt ?? _t0,
  updatedAt: updatedAt ?? _t0,
  lastOpenedAt: lastOpenedAt,
);

Task task(
  String id, {
  DateTime? dueDate,
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  bool favorite = false,
}) => Task(
  id: id,
  title: id,
  dueDate: dueDate,
  status: status,
  priority: priority,
  isFavorite: favorite,
  createdAt: _t0,
  updatedAt: _t0,
);

Note note(String id, {String title = 'Note', bool favorite = false}) => Note(
  id: id,
  title: title,
  isFavorite: favorite,
  createdAt: _t0,
  updatedAt: _t0,
);

Category category(String id, String name) => Category(
  id: id,
  name: name,
  icon: 'code',
  primaryColor: 0,
  secondaryColor: 0,
  createdAt: _t0,
  updatedAt: _t0,
);

void main() {
  final now = DateTime(2026, 9, 30, 10);
  final today = DateTime(2026, 9, 30);

  group('stats', () {
    test('counts items and averages resource progress', () {
      final stats = DashboardStats.of(
        categories: [category('c', 'C')],
        resources: [resource('a', progress: 100), resource('b', progress: 25)],
        notes: [
          note('n1'),
          note('blank', title: ''),
        ],
        tasks: [
          task('open'),
          task('doing', status: TaskStatus.inProgress),
          task('done', status: TaskStatus.completed),
        ],
      );
      expect(stats.resources, 2);
      expect(stats.notes, 1, reason: 'blank notes are not counted');
      expect(stats.pendingTasks, 2);
      expect(stats.completedTasks, 1);
      expect(stats.categories, 1);
      expect(stats.overallProgress, 63, reason: '(100 + 25) / 2 rounded');
      expect(stats.isEmpty, isFalse);
    });

    test('no resources means no overall progress', () {
      final stats = DashboardStats.of(
        categories: const [],
        resources: const [],
        notes: const [],
        tasks: const [],
      );
      expect(stats.overallProgress, isNull);
      expect(stats.isEmpty, isTrue);
    });
  });

  test('continue learning: started, unfinished, most recently opened', () {
    final list = DashboardSelectors.continueLearning([
      resource('not-started'),
      resource('done', progress: 100),
      resource('old', progress: 50, lastOpenedAt: DateTime(2026, 9, 10)),
      resource('recent', progress: 20, lastOpenedAt: DateTime(2026, 9, 29)),
      resource('never-opened', progress: 10, updatedAt: DateTime(2026, 9, 20)),
    ]);
    expect(list.map((r) => r.id), ['recent', 'never-opened', 'old']);
  });

  test('continue learning respects the limit', () {
    final list = DashboardSelectors.continueLearning([
      for (var i = 0; i < 5; i++) resource('r$i', progress: 50),
    ], limit: 3);
    expect(list, hasLength(3));
  });

  test('recent resources: newest first, limited', () {
    final list = DashboardSelectors.recentResources([
      for (var d = 1; d <= 7; d++)
        resource('r$d', createdAt: DateTime(2026, 9, d)),
    ]);
    expect(list.map((r) => r.id), ['r7', 'r6', 'r5', 'r4', 'r3']);
  });

  test(
    'today: due today or overdue and open; overdue first, then priority',
    () {
      final list = DashboardSelectors.todaysTasks([
        task('tomorrow', dueDate: DateTime(2026, 10, 1)),
        task('today-low', dueDate: today, priority: TaskPriority.low),
        task('today-high', dueDate: today, priority: TaskPriority.high),
        task('late', dueDate: DateTime(2026, 9, 25)),
        task(
          'late-done',
          dueDate: DateTime(2026, 9, 25),
          status: TaskStatus.completed,
        ),
        task('no-date'),
      ], now);
      expect(list.map((t) => t.id), ['late', 'today-high', 'today-low']);
    },
  );

  test('category progress: only categories with resources, by name', () {
    final categories = [
      category('b', 'Beta'),
      category('a', 'alpha'),
      category('empty', 'Empty'),
    ];
    final progress = LearningProgress.byCategory([
      resource('r1', categoryId: 'a', progress: 40),
      resource('r2', categoryId: 'b', progress: 100),
    ]);
    final list = DashboardSelectors.categoryProgress(categories, progress);
    expect(list.map((e) => e.category.id), ['a', 'b']);
    expect(list.first.progress.percent, 40);
  });

  test('favorites mix kinds, newest first, skip blank notes', () {
    final items = DashboardSelectors.favorites(
      resources: [
        resource('r', favorite: true, updatedAt: DateTime(2026, 9, 3)),
        resource('not-fav'),
      ],
      notes: [
        Note(
          id: 'n',
          title: 'N',
          isFavorite: true,
          createdAt: _t0,
          updatedAt: DateTime(2026, 9, 5),
        ),
        note('blank', title: '', favorite: true),
      ],
      tasks: [task('t', favorite: true)],
    );
    expect(items.map((i) => i.runtimeType), [
      FavoriteNote,
      FavoriteResource,
      FavoriteTask,
    ]);
  });
}
