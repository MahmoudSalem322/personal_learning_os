import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/notes/domain/markdown_text.dart';

void main() {
  const doc = '''
# Title

Some **bold** and _italic_ with a [link](https://a.dev) and `code`.

- [x] done
- [ ] todo

```
- [ ] not a task, it is code
```

> quoted
1. [ ] numbered task''';

  group('excerpt', () {
    test('strips markdown and skips code blocks', () {
      expect(
        MarkdownText.excerpt(doc),
        'Title Some bold and italic with a link and code. done todo quoted '
        'numbered task',
      );
    });

    test('truncates with an ellipsis', () {
      final text = MarkdownText.excerpt('word ' * 100, maxLength: 20);
      expect(text.length, lessThanOrEqualTo(21));
      expect(text, endsWith('…'));
    });

    test('is empty for empty content', () {
      expect(MarkdownText.excerpt(''), '');
    });
  });

  test('taskCounts ignores code blocks', () {
    expect(MarkdownText.taskCounts(doc), (done: 1, total: 3));
    expect(MarkdownText.taskCounts('no tasks'), (done: 0, total: 0));
  });

  group('toggleTask', () {
    test('toggles the nth task in document order', () {
      final once = MarkdownText.toggleTask(doc, 1);
      expect(once, contains('- [x] todo'));
      expect(MarkdownText.taskCounts(once), (done: 2, total: 3));

      final back = MarkdownText.toggleTask(once, 0);
      expect(back, contains('- [ ] done'));
    });

    test('skips tasks inside code blocks', () {
      final toggled = MarkdownText.toggleTask(doc, 2);
      expect(toggled, contains('1. [x] numbered task'));
      expect(toggled, contains('- [ ] not a task, it is code'));
    });

    test('leaves content unchanged for a missing index', () {
      expect(MarkdownText.toggleTask(doc, 9), doc);
    });
  });
}
