import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';

Resource sample({String? categoryId = 'c1', DateTime? lastOpenedAt}) =>
    Resource(
      id: 'r1',
      title: 'Riverpod',
      description: 'State management',
      url: 'https://riverpod.dev',
      type: ResourceType.documentation,
      categoryId: categoryId,
      tags: const ['flutter', 'state'],
      isFavorite: true,
      progress: 40,
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 2),
      lastOpenedAt: lastOpenedAt,
    );

void main() {
  test('round-trips through JSON', () {
    final r = sample(lastOpenedAt: DateTime.utc(2026, 9, 3));
    expect(Resource.fromJson(r.toJson()), r);
    final uncategorized = sample(categoryId: null);
    expect(Resource.fromJson(uncategorized.toJson()), uncategorized);
  });

  test('tolerates missing and odd optional fields', () {
    final r = Resource.fromJson({
      'id': 'x',
      'title': 'T',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-01T00:00:00.000Z',
      'type': 'hologram',
      'tags': ['a', 3, 'b'],
      'progress': 250,
      'categoryId': '',
    });
    expect(r.type, ResourceType.other);
    expect(r.tags, ['a', 'b']);
    expect(r.progress, 100);
    expect(r.categoryId, isNull);
    expect(r.url, '');
    expect(r.isFavorite, isFalse);
    expect(r.lastOpenedAt, isNull);
  });

  test('rejects records without required fields', () {
    expect(
      () => Resource.fromJson(sample().toJson()..remove('title')),
      throwsFormatException,
    );
  });

  test('clamps progress and exposes status helpers', () {
    final r = sample();
    expect(r.copyWith(progress: -5).progress, 0);
    expect(r.copyWith(progress: 0).isStarted, isFalse);
    expect(r.copyWith(progress: 100).isCompleted, isTrue);
  });

  test('copyWith can clear the category', () {
    expect(sample().copyWith(categoryId: null).categoryId, isNull);
    expect(sample().copyWith(title: 'x').categoryId, 'c1');
  });

  test('tags are immutable', () {
    expect(() => sample().tags.add('x'), throwsUnsupportedError);
  });

  group('ResourceType.detect', () {
    final cases = {
      'https://www.youtube.com/watch?v=1': ResourceType.youtube,
      'https://youtu.be/abc': ResourceType.youtube,
      'https://github.com/flutter/flutter': ResourceType.github,
      'https://example.com/paper.PDF': ResourceType.pdf,
      'https://www.udemy.com/course/x': ResourceType.course,
      'https://medium.com/@me/post': ResourceType.article,
      'https://docs.flutter.dev': ResourceType.documentation,
      'https://example.com/docs/start': ResourceType.documentation,
      'https://flutter.dev': ResourceType.website,
    };
    for (final MapEntry(key: url, value: type) in cases.entries) {
      test(url, () => expect(ResourceType.detect(url), type));
    }
  });
}
