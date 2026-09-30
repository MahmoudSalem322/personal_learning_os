import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/categories/presentation/categories_providers.dart';
import 'package:personal_learning_os/features/dashboard/domain/dashboard_summary.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notes/domain/note_filter.dart';
import 'package:personal_learning_os/features/notes/presentation/notes_providers.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/note_card.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_filter.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_card.dart';
import 'package:personal_learning_os/features/search/domain/search_index.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';
import 'package:personal_learning_os/features/tasks/domain/task_filter.dart';
import 'package:personal_learning_os/features/tasks/presentation/tasks_providers.dart';
import 'package:personal_learning_os/features/tasks/presentation/widgets/task_card.dart';

import '../helpers/test_app.dart';

/// The spec's scale target: 1000+ of each.
const int _n = 1000;

final _t0 = DateTime.utc(2026);

List<Category> categories() => [
  for (var i = 0; i < 20; i++)
    Category(
      id: 'c$i',
      name: 'Category $i',
      icon: 'code',
      primaryColor: 0xFF3B82F6,
      secondaryColor: 0xFF6366F1,
      createdAt: _t0,
      updatedAt: _t0,
    ),
];

List<Resource> resources() => [
  for (var i = 0; i < _n; i++)
    Resource(
      id: 'r$i',
      title: 'Resource $i about widgets',
      description: 'Description of resource $i',
      url: 'https://example.com/$i',
      type: ResourceType.values[i % ResourceType.values.length],
      categoryId: 'c${i % 20}',
      tags: ['tag${i % 30}', 'flutter'],
      progress: i % 101,
      isFavorite: i.isEven,
      createdAt: _t0.add(Duration(minutes: i)),
      updatedAt: _t0.add(Duration(minutes: i)),
    ),
];

List<Note> notes() => [
  for (var i = 0; i < _n; i++)
    Note(
      id: 'n$i',
      title: 'Note $i',
      content: '# Heading $i\n\n${'Some markdown text. ' * 40}\n- [ ] item',
      categoryId: 'c${i % 20}',
      tags: ['tag${i % 30}'],
      createdAt: _t0.add(Duration(minutes: i)),
      updatedAt: _t0.add(Duration(minutes: i)),
    ),
];

List<Task> tasks() => [
  for (var i = 0; i < _n; i++)
    Task(
      id: 't$i',
      title: 'Task $i',
      categoryId: 'c${i % 20}',
      dueDate: DateTime(2026, 9, 1).add(Duration(days: i % 60)),
      status: TaskStatus.values[i % 3],
      priority: TaskPriority.values[i % 3],
      tags: ['tag${i % 30}'],
      createdAt: _t0.add(Duration(minutes: i)),
      updatedAt: _t0.add(Duration(minutes: i)),
    ),
];

/// Runs [body] [times] times and returns the slowest run.
Duration slowest(int times, void Function() body) {
  var worst = Duration.zero;
  for (var i = 0; i < times; i++) {
    final watch = Stopwatch()..start();
    body();
    watch.stop();
    if (watch.elapsed > worst) worst = watch.elapsed;
  }
  return worst;
}

Future<ProviderContainer> pumpWithLargeData(WidgetTester tester) async {
  final container = await tester.pumpLearningOs();
  await tester.io(() async {
    await container.read(categoryRepositoryProvider).saveAll(categories());
    await container.read(resourceRepositoryProvider).saveAll(resources());
    await container.read(noteRepositoryProvider).saveAll(notes());
    await container.read(taskRepositoryProvider).saveAll(tasks());
  });
  return container;
}

void main() {
  group('logic stays fast with $_n items of each kind', () {
    // Generous limits: this guards against accidental O(n²) work, not
    // micro-benchmarks. Typical runs are a few milliseconds.
    const limit = Duration(milliseconds: 150);
    final r = resources();
    final n = notes();
    final t = tasks();
    final c = categories();
    final now = DateTime(2026, 9, 30, 10);

    test('filtering and sorting lists', () {
      const resourceFilter = ResourceFilter(
        query: 'widgets',
        sort: ResourceSort.title,
      );
      const noteFilter = NoteFilter(query: 'markdown');
      const taskFilter = TaskFilter(query: 'task', sort: TaskSort.priority);
      expect(slowest(5, () => resourceFilter.apply(r)), lessThan(limit));
      expect(slowest(5, () => noteFilter.apply(n)), lessThan(limit));
      expect(slowest(5, () => taskFilter.apply(t, now: now)), lessThan(limit));
    });

    test('building the search index and searching', () {
      late SearchIndex index;
      expect(
        slowest(
          3,
          () => index = SearchIndex(
            categories: c,
            resources: r,
            notes: n,
            tasks: t,
          ),
        ),
        lessThan(limit),
      );
      for (final query in ['w', 'widgets', 'note 99', '#tag1', 'markdown']) {
        expect(
          slowest(5, () => index.search(query)),
          lessThan(limit),
          reason: query,
        );
      }
    });

    test('dashboard summaries', () {
      expect(
        slowest(5, () {
          DashboardStats.of(categories: c, resources: r, notes: n, tasks: t);
          DashboardSelectors.continueLearning(r);
          DashboardSelectors.todaysTasks(t, now);
          DashboardSelectors.favorites(resources: r, notes: n, tasks: t);
        }),
        lessThan(limit),
      );
    });
  });

  testWidgets('long lists only build what is on screen', (tester) async {
    final container = await pumpWithLargeData(tester);
    final router = container.read(appRouterProvider);

    for (final (path, type) in [
      ('/resources', ResourceCard),
      ('/notes', NoteCard),
      ('/tasks', TaskCard),
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      final built = find.byType(type).evaluate().length;
      expect(built, greaterThan(0), reason: path);
      expect(built, lessThan(60), reason: '$path builds lazily');

      // Scrolling far down works and stays lazy.
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -20000));
      await tester.pumpAndSettle();
      expect(find.byType(type).evaluate().length, lessThan(60));
      expect(tester.takeException(), isNull);
    }

    router.go('/dashboard');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
