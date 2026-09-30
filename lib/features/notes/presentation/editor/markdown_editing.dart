import 'package:flutter/services.dart';

/// Block formats the toolbar can apply to the current line(s).
enum MarkdownBlock {
  heading1('# '),
  heading2('## '),
  heading3('### '),
  bullet('- '),
  numbered('1. '),
  task('- [ ] '),
  quote('> ');

  const MarkdownBlock(this.prefix);

  final String prefix;
}

/// Pure text transformations behind the editor toolbar and shortcuts.
/// Each takes the current [TextEditingValue] and returns the new one, with
/// a sensible selection, so they're easy to test.
abstract final class MarkdownEditing {
  static final RegExp _blockPrefix = RegExp(
    r'^(#{1,6}\s+|>\s?|\s*(?:[-*+]|\d+[.)])\s+(?:\[[ xX]\]\s+)?)',
  );

  /// Wraps the selection in [marker] (e.g. `**` for bold), or removes it if
  /// the selection is already wrapped. With no selection, inserts the pair
  /// and places the cursor between them.
  static TextEditingValue toggleInline(TextEditingValue value, String marker) {
    final sel = _safe(value);
    final text = value.text;
    final before = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after = text.substring(sel.end);
    final m = marker.length;

    if (before.endsWith(marker) && after.startsWith(marker)) {
      return TextEditingValue(
        text:
            '${before.substring(0, before.length - m)}$selected'
            '${after.substring(m)}',
        selection: TextSelection(
          baseOffset: sel.start - m,
          extentOffset: sel.end - m,
        ),
      );
    }
    return TextEditingValue(
      text: '$before$marker$selected$marker$after',
      selection: TextSelection(
        baseOffset: sel.start + m,
        extentOffset: sel.end + m,
      ),
    );
  }

  /// Applies [block] to every line touched by the selection. If all those
  /// lines already have it, it's removed instead (toggle). Any other block
  /// prefix is replaced, so "## Title" → bullet gives "- Title".
  static TextEditingValue toggleBlock(
    TextEditingValue value,
    MarkdownBlock block,
  ) {
    final sel = _safe(value);
    final text = value.text;
    final lineStart = _lineStart(text, sel.start);
    var lineEnd = text.indexOf('\n', sel.end);
    if (lineEnd == -1) lineEnd = text.length;

    final lines = text.substring(lineStart, lineEnd).split('\n');
    final allHave = lines.every((l) => l.startsWith(block.prefix));
    var number = 1;
    final changed = [
      for (final line in lines)
        () {
          final bare = line.replaceFirst(_blockPrefix, '');
          if (allHave) return bare;
          final prefix = block == MarkdownBlock.numbered
              ? '${number++}. '
              : block.prefix;
          return '$prefix$bare';
        }(),
    ].join('\n');

    final newText = text.replaceRange(lineStart, lineEnd, changed);
    final delta = changed.length - (lineEnd - lineStart);
    return TextEditingValue(
      text: newText,
      selection: sel.isCollapsed
          ? TextSelection.collapsed(offset: lineStart + changed.length)
          : TextSelection(baseOffset: lineStart, extentOffset: lineEnd + delta),
    );
  }

  /// Turns the selection into `[text](url)` and selects the url
  /// placeholder so it can be typed over.
  static TextEditingValue insertLink(TextEditingValue value) {
    final sel = _safe(value);
    final label = value.text.substring(sel.start, sel.end);
    const url = 'https://';
    final inserted = '[$label]($url)';
    final urlStart = sel.start + label.length + 3;
    return TextEditingValue(
      text: value.text.replaceRange(sel.start, sel.end, inserted),
      selection: TextSelection(
        baseOffset: urlStart,
        extentOffset: urlStart + url.length,
      ),
    );
  }

  /// Wraps the selection (or an empty line) in a fenced code block.
  static TextEditingValue insertCodeBlock(TextEditingValue value) {
    final sel = _safe(value);
    final text = value.text;
    final code = text.substring(sel.start, sel.end);
    final needsLeadingBreak = sel.start > 0 && text[sel.start - 1] != '\n';
    final lead = needsLeadingBreak ? '\n' : '';
    final block = '$lead```\n$code\n```\n';
    final cursor = sel.start + lead.length + 4 + code.length;
    return TextEditingValue(
      text: text.replaceRange(sel.start, sel.end, block),
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// Index of the first character of the line containing [offset].
  static int _lineStart(String text, int offset) =>
      offset <= 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;

  static TextSelection _safe(TextEditingValue value) {
    final length = value.text.length;
    final sel = value.selection;
    if (!sel.isValid) return TextSelection.collapsed(offset: length);
    final start = sel.start.clamp(0, length);
    final end = sel.end.clamp(0, length);
    return TextSelection(baseOffset: start, extentOffset: end);
  }
}

/// Continues lists when Enter is pressed at the end of a list item, like
/// most writing apps: "- a⏎" gives "- ", "3. a⏎" gives "4. ", "- [x] a⏎"
/// gives "- [ ] ". Enter on an empty item removes its marker instead.
class ListContinuationFormatter extends TextInputFormatter {
  static final RegExp _item = RegExp(
    r'^(\s*)([-*+]|(\d+)([.)]))\s+(\[[ xX]\]\s+)?(.*)$',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only react to a single newline typed at a collapsed cursor.
    final cursor = newValue.selection.baseOffset;
    if (!newValue.selection.isCollapsed ||
        newValue.text.length != oldValue.text.length + 1 ||
        cursor < 1 ||
        newValue.text[cursor - 1] != '\n') {
      return newValue;
    }

    final text = newValue.text;
    final prevStart = MarkdownEditing._lineStart(text, cursor - 1);
    final prevLine = text.substring(prevStart, cursor - 1);
    final match = _item.firstMatch(prevLine);
    if (match == null) return newValue;

    final indent = match.group(1)!;
    final hasTask = match.group(5) != null;
    final body = match.group(6)!;

    if (body.trim().isEmpty) {
      // Empty item: end the list by clearing the marker and the newline.
      final cleared = text.replaceRange(prevStart, cursor, '');
      return TextEditingValue(
        text: cleared,
        selection: TextSelection.collapsed(offset: prevStart),
      );
    }

    final number = match.group(3);
    final marker = number != null
        ? '${int.parse(number) + 1}${match.group(4)}'
        : match.group(2)!;
    final prefix = '$indent$marker ${hasTask ? '[ ] ' : ''}';
    return TextEditingValue(
      text: text.replaceRange(cursor, cursor, prefix),
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
  }
}
