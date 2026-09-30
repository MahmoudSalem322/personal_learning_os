import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/search/domain/search_hit.dart';
import 'package:personal_learning_os/features/search/domain/search_index.dart';
import 'package:personal_learning_os/features/tasks/domain/task.dart';

final _t0 = DateTime.utc(2026, 9, 1);
DateTime _at(int day) => DateTime.utc(2026, 9, day);

Category category(String id, String name, {String description = ''}) =>
    Category(
      id: id,
      name: name,
      description: description,
      icon: 'code',
      primaryColor: 0,
      secondaryColor: 0,
      createdAt: _t0,
      updatedAt: _t0,
    );

Resource resource(
  String id,
  String title, {
  String description = '',
  String url = '',
  List<String> tags = const [],
  DateTime? updatedAt,
}) => Resource(
  id: id,
  title: title,
  description: description,
  url: url,
  type: ResourceType.website,
  tags: tags,
  createdAt: _t0,
  updatedAt: updatedAt ?? _t0,
);

Note note(
  String id,
  String title, {
  String content = '',
  List<String> tags = const [],
}) => Note(
  id: id,
  title: title,
  content: content,
  tags: tags,
  createdAt: _t0,
  updatedAt: _t0,
);

Task task(String id, String title, {List<String> tags = const []}) =>
    Task(id: id, title: title, tags: tags, createdAt: _t0, updatedAt: _t0);

List<String> ids(SearchResults results, SearchKind kind) => [
  for (final group in results.groups)
    if (group.kind == kind)
      for (final hit in group.hits)
        switch (hit) {
          CategoryHit(:final category) => category.id,
          ResourceHit(:final resource) => resource.id,
          NoteHit(:final note) => note.id,
          TaskHit(:final task) => task.id,
          TagHit(:final tag) => tag,
        },
];

void main() {
  final index = SearchIndex(
    categories: [
      category('c-flutter', 'Flutter', description: 'Cross-platform UI'),
      category('c-dart', 'Dart'),
    ],
    resources: [
      resource('r-docs', 'Flutter docs', tags: ['flutter', 'docs']),
      resource('r-layout', 'Understanding layout in Flutter'),
      resource(
        'r-riverpod',
        'Riverpod guide',
        description: 'State management for Flutter apps',
        tags: ['state-management'],
      ),
      resource('r-git', 'Pro Git', url: 'https://git-scm.com/book'),
    ],
    notes: [
      note(
        'n-select',
        'Riverpod select',
        content: 'Use select to rebuild less',
      ),
      note('n-blank', ''),
      note('n-git', 'Git cheatsheet', content: 'rebase -i', tags: ['git']),
    ],
    tasks: [
      task('t-learn', 'Learn Riverpod', tags: ['flutter']),
      task('t-git', 'Install Git'),
    ],
  );

  test('an empty query finds nothing', () {
    expect(index.search('').isEmpty, isTrue);
    expect(index.search('   ').isEmpty, isTrue);
  });

  test('searches every kind and groups results in a fixed order', () {
    final results = index.search('riverpod');
    expect(results.groups.map((g) => g.kind), [
      SearchKind.resource,
      SearchKind.note,
      SearchKind.task,
    ]);
    expect(ids(results, SearchKind.resource), ['r-riverpod']);
    expect(ids(results, SearchKind.note), ['n-select']);
    expect(ids(results, SearchKind.task), ['t-learn']);
  });

  test('ranks title prefix above title contains above body match', () {
    final results = index.search('flutter');
    expect(ids(results, SearchKind.category), ['c-flutter']);
    // "Flutter docs" (prefix) > "Understanding layout in Flutter" (word)
    // > "Riverpod guide" (description only).
    expect(ids(results, SearchKind.resource), [
      'r-docs',
      'r-layout',
      'r-riverpod',
    ]);
  });

  test('is case-insensitive and needs every word', () {
    expect(ids(index.search('GIT CHEAT'), SearchKind.note), ['n-git']);
    expect(index.search('git flutter').groups, isEmpty);
  });

  test('matches descriptions, note content and URLs', () {
    expect(ids(index.search('cross-platform'), SearchKind.category), [
      'c-flutter',
    ]);
    expect(ids(index.search('rebase'), SearchKind.note), ['n-git']);
    expect(ids(index.search('git-scm'), SearchKind.resource), ['r-git']);
  });

  test('blank notes are not searchable', () {
    final results = index.search('a');
    expect(ids(results, SearchKind.note), isNot(contains('n-blank')));
  });

  test('# searches tags only and lists matching tags', () {
    final results = index.search('#flutter');
    expect(ids(results, SearchKind.resource), ['r-docs']);
    expect(ids(results, SearchKind.task), ['t-learn']);
    expect(ids(results, SearchKind.category), isEmpty);
    final tags = results.groups.singleWhere((g) => g.kind == SearchKind.tag);
    expect((tags.hits.single as TagHit).tag, 'flutter');
    expect((tags.hits.single as TagHit).count, 2);
  });

  test('a lone # lists every tag, most used first', () {
    final results = index.search('#');
    final tags = results.groups.single;
    expect(tags.kind, SearchKind.tag);
    expect((tags.hits.first as TagHit).tag, 'flutter');
  });

  test('plain text also suggests matching tags', () {
    final results = index.search('state');
    expect(ids(results, SearchKind.tag), ['state-management']);
  });

  test('limits each group but reports the total', () {
    final many = SearchIndex(
      categories: const [],
      resources: [
        for (var i = 1; i <= 8; i++)
          resource('r$i', 'Widget $i', updatedAt: _at(i)),
      ],
      notes: const [],
      tasks: const [],
    );
    final group = many.search('widget', limitPerKind: 3).groups.single;
    expect(group.total, 8);
    expect(group.hasMore, isTrue);
    // Same score: most recently updated first.
    expect(ids(many.search('widget', limitPerKind: 3), SearchKind.resource), [
      'r8',
      'r7',
      'r6',
    ]);
  });
}
