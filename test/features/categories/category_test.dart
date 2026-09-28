import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';

final _created = DateTime.utc(2026, 9, 1, 10);
final _updated = DateTime.utc(2026, 9, 2, 12);

Category _category() => Category(
  id: 'c1',
  name: 'Flutter',
  description: 'Widgets',
  icon: 'mobile',
  primaryColor: 0xFF3B82F6,
  secondaryColor: 0xFF0EA5E9,
  createdAt: _created,
  updatedAt: _updated,
);

void main() {
  test('round-trips through JSON', () {
    final category = _category();
    expect(Category.fromJson(category.toJson()), category);
  });

  test('stores timestamps as UTC ISO-8601 strings', () {
    final json = _category().toJson();
    expect(json['createdAt'], '2026-09-01T10:00:00.000Z');
  });

  test('missing description defaults to empty', () {
    final json = _category().toJson()..remove('description');
    expect(Category.fromJson(json).description, '');
  });

  test('rejects records with missing or mistyped fields', () {
    expect(
      () => Category.fromJson(_category().toJson()..remove('name')),
      throwsFormatException,
    );
    expect(
      () => Category.fromJson({..._category().toJson(), 'primaryColor': 'x'}),
      throwsFormatException,
    );
    expect(
      () => Category.fromJson({..._category().toJson(), 'createdAt': 'soon'}),
      throwsFormatException,
    );
  });

  test('copyWith keeps id and createdAt', () {
    final renamed = _category().copyWith(name: 'Dart');
    expect(renamed.name, 'Dart');
    expect(renamed.id, 'c1');
    expect(renamed.createdAt, _created);
  });
}
