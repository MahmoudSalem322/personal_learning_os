import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/tags/domain/tags.dart';

void main() {
  test('normalize lowercases, strips # and joins words with -', () {
    expect(TagRules.normalize('#State Management '), 'state-management');
    expect(TagRules.normalize('##Flutter'), 'flutter');
    expect(TagRules.normalize('UI/UX!'), 'uiux');
    expect(TagRules.normalize(' -a--b- '), 'a-b');
    expect(TagRules.normalize('   '), '');
  });

  test('normalize keeps letters from any script', () {
    expect(TagRules.normalize('#تعلم الآلة'), 'تعلم-الآلة');
  });

  test('normalize caps the length', () {
    expect(TagRules.normalize('x' * 50), hasLength(TagRules.maxLength));
  });

  test('normalizeAll removes empties and duplicates, keeping order', () {
    expect(
      TagRules.normalizeAll(['Dart', '#dart', '', 'flutter', 'FLUTTER', '#']),
      ['dart', 'flutter'],
    );
  });

  test('parse splits on commas and spaces', () {
    expect(TagRules.parse('flutter, #dart  ui'), ['flutter', 'dart', 'ui']);
  });
}
