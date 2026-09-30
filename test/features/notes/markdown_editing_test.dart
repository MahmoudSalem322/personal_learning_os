import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/notes/presentation/editor/markdown_editing.dart';

TextEditingValue value(String text, int start, [int? end]) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: start, extentOffset: end ?? start),
);

String selected(TextEditingValue v) =>
    v.text.substring(v.selection.start, v.selection.end);

void main() {
  group('toggleInline', () {
    test('wraps and keeps the selection on the text', () {
      final v = MarkdownEditing.toggleInline(value('make bold', 5, 9), '**');
      expect(v.text, 'make **bold**');
      expect(selected(v), 'bold');
    });

    test('unwraps an already wrapped selection', () {
      final v = MarkdownEditing.toggleInline(
        value('make **bold**', 7, 11),
        '**',
      );
      expect(v.text, 'make bold');
      expect(selected(v), 'bold');
    });

    test('inserts an empty pair at the cursor', () {
      final v = MarkdownEditing.toggleInline(value('ab', 1), '_');
      expect(v.text, 'a__b');
      expect(v.selection.baseOffset, 2);
    });
  });

  group('toggleBlock', () {
    test('adds a prefix to the current line', () {
      final v = MarkdownEditing.toggleBlock(
        value('one\ntwo', 5),
        MarkdownBlock.heading2,
      );
      expect(v.text, 'one\n## two');
    });

    test('removes the prefix when every line has it', () {
      final v = MarkdownEditing.toggleBlock(
        value('- a\n- b', 0, 7),
        MarkdownBlock.bullet,
      );
      expect(v.text, 'a\nb');
    });

    test('replaces a different block prefix', () {
      final v = MarkdownEditing.toggleBlock(
        value('## Title', 3),
        MarkdownBlock.task,
      );
      expect(v.text, '- [ ] Title');
    });

    test('numbers each selected line', () {
      final v = MarkdownEditing.toggleBlock(
        value('a\nb\nc', 0, 5),
        MarkdownBlock.numbered,
      );
      expect(v.text, '1. a\n2. b\n3. c');
    });
  });

  test('insertLink selects the url placeholder', () {
    final v = MarkdownEditing.insertLink(value('see docs', 4, 8));
    expect(v.text, 'see [docs](https://)');
    expect(selected(v), 'https://');
  });

  test('insertCodeBlock wraps the selection on its own lines', () {
    final v = MarkdownEditing.insertCodeBlock(value('run x()', 4, 7));
    expect(v.text, 'run \n```\nx()\n```\n');
  });

  group('ListContinuationFormatter', () {
    final formatter = ListContinuationFormatter();

    TextEditingValue typeEnter(String before) {
      final old = TextEditingValue(
        text: before,
        selection: TextSelection.collapsed(offset: before.length),
      );
      final typed = TextEditingValue(
        text: '$before\n',
        selection: TextSelection.collapsed(offset: before.length + 1),
      );
      return formatter.formatEditUpdate(old, typed);
    }

    test('continues bullets, numbers and tasks', () {
      expect(typeEnter('- item').text, '- item\n- ');
      expect(typeEnter('3. step').text, '3. step\n4. ');
      expect(typeEnter('- [x] done').text, '- [x] done\n- [ ] ');
      expect(typeEnter('  * nested').text, '  * nested\n  * ');
    });

    test('ends the list on an empty item', () {
      final v = typeEnter('- a\n- ');
      expect(v.text, '- a\n');
      expect(v.selection.baseOffset, 4);
    });

    test('leaves plain lines alone', () {
      expect(typeEnter('hello').text, 'hello\n');
    });
  });
}
