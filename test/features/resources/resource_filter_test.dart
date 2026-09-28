import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/resources/domain/learning_progress.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_filter.dart';

final _base = DateTime.utc(2026, 9, 1);

Resource r(
  String id, {
  String? title,
  ResourceType type = ResourceType.website,
  String? categoryId,
  List<String> tags = const [],
  int progress = 0,
  bool favorite = false,
  int createdDay = 0,
  int? openedDay,
}) => Resource(
  id: id,
  title: title ?? id,
  type: type,
  categoryId: categoryId,
  tags: tags,
  progress: progress,
  isFavorite: favorite,
  createdAt: _base.add(Duration(days: createdDay)),
  updatedAt: _base,
  lastOpenedAt: openedDay == null ? null : _base.add(Duration(days: openedDay)),
);

List<String> ids(List<Resource> list) => list.map((e) => e.id).toList();

void main() {
  final all = [
    r(
      'flutter',
      categoryId: 'c1',
      tags: ['flutter'],
      progress: 50,
      createdDay: 1,
      openedDay: 5,
    ),
    r(
      'dart',
      title: 'Dart tour',
      type: ResourceType.documentation,
      categoryId: 'c2',
      tags: ['dart'],
      progress: 100,
      createdDay: 2,
    ),
    r(
      'video',
      type: ResourceType.youtube,
      favorite: true,
      createdDay: 3,
      openedDay: 9,
    ),
  ];

  test('empty filter keeps everything, newest first', () {
    expect(ids(const ResourceFilter().apply(all)), [
      'video',
      'dart',
      'flutter',
    ]);
    expect(const ResourceFilter().isEmpty, isTrue);
  });

  test('filters by type, category, tag and favorites', () {
    expect(ids(const ResourceFilter(type: ResourceType.youtube).apply(all)), [
      'video',
    ]);
    expect(ids(const ResourceFilter(categoryId: 'c2').apply(all)), ['dart']);
    expect(
      ids(
        const ResourceFilter(categoryId: ResourceFilter.uncategorized)
            .apply(all),
      ),
      ['video'],
    );
    expect(ids(const ResourceFilter(tag: 'flutter').apply(all)), ['flutter']);
    expect(ids(const ResourceFilter(favoritesOnly: true).apply(all)), [
      'video',
    ]);
  });

  test('filters by progress bucket', () {
    List<String> by(ProgressFilter p) =>
        ids(ResourceFilter(progress: p).apply(all));
    expect(by(ProgressFilter.notStarted), ['video']);
    expect(by(ProgressFilter.inProgress), ['flutter']);
    expect(by(ProgressFilter.completed), ['dart']);
  });

  test('search matches title, url and #tags', () {
    expect(ids(const ResourceFilter(query: 'TOUR').apply(all)), ['dart']);
    expect(ids(const ResourceFilter(query: '#flut').apply(all)), ['flutter']);
  });

  test('sorts by title, progress and recently opened', () {
    expect(ids(const ResourceFilter(sort: ResourceSort.title).apply(all)), [
      'dart',
      'flutter',
      'video',
    ]);
    expect(ids(const ResourceFilter(sort: ResourceSort.progress).apply(all)), [
      'dart',
      'flutter',
      'video',
    ]);
    expect(
      ids(const ResourceFilter(sort: ResourceSort.recentlyOpened).apply(all)),
      ['video', 'flutter', 'dart'],
    );
  });

  test('copyWith can clear filters; cleared keeps query and sort', () {
    const f = ResourceFilter(
      query: 'x',
      type: ResourceType.book,
      tag: 't',
      sort: ResourceSort.title,
    );
    expect(f.copyWith(type: null).type, isNull);
    expect(f.copyWith(query: 'y').type, ResourceType.book);
    final cleared = f.cleared();
    expect(cleared.hasFilters, isFalse);
    expect(cleared.query, 'x');
    expect(cleared.sort, ResourceSort.title);
  });

  group('LearningProgress', () {
    test('is the rounded mean of resource progress', () {
      final p = LearningProgress.of([
        r('a', progress: 100),
        r('b', progress: 50),
        r('c', progress: 0),
      ]);
      expect(p.resourceCount, 3);
      expect(p.completedCount, 1);
      expect(p.percent, 50);
      expect(
        LearningProgress.of([r('a', progress: 33), r('b', progress: 34)])
            .percent,
        34,
      ); // 33.5 rounds up
    });

    test('has no percentage without resources', () {
      expect(LearningProgress.of(const []).percent, isNull);
    });

    test('groups by category and skips uncategorized', () {
      final map = LearningProgress.byCategory(all);
      expect(map.keys, unorderedEquals(['c1', 'c2']));
      expect(map['c1']!.percent, 50);
      expect(map['c2']!.completedCount, 1);
    });
  });
}
