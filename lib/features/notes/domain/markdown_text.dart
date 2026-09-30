/// Text helpers for Markdown note content. Line-based and cheap, so they
/// can run for every visible card without parsing whole documents.
abstract final class MarkdownText {
  static final RegExp _fence = RegExp(r'^\s*(```|~~~)');
  static final RegExp _task = RegExp(
    r'^(\s*(?:[-*+]|\d+[.)])\s+\[)([ xX])(\])',
  );

  /// A short plain-text preview: Markdown markers removed, code blocks and
  /// blank lines skipped, lines joined with spaces.
  static String excerpt(String content, {int maxLength = 240}) {
    final buffer = StringBuffer();
    var inFence = false;
    for (final raw in content.split('\n')) {
      if (_fence.hasMatch(raw)) {
        inFence = !inFence;
        continue;
      }
      if (inFence) continue;
      final line = _stripLine(raw);
      if (line.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(line);
      if (buffer.length >= maxLength) break;
    }
    final text = buffer.toString();
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength).trimRight()}…';
  }

  static String _stripLine(String line) => line
      .replaceFirst(RegExp(r'^\s*#{1,6}\s+'), '')
      .replaceFirst(RegExp(r'^\s*>\s?'), '')
      .replaceFirst(RegExp(r'^\s*(?:[-*+]|\d+[.)])\s+(\[[ xX]\]\s+)?'), '')
      .replaceFirst(RegExp(r'^\s*([-*_]\s*){3,}$'), '')
      .replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!)
      .replaceAll(RegExp(r'(\*\*|__|~~|`)'), '')
      .replaceAllMapped(
        RegExp(r'(^|\W)[*_]([^*_]+)[*_](?=\W|$)'),
        (m) => '${m.group(1)}${m.group(2)}',
      )
      .trim();

  /// Checklist progress: how many `- [x]` items out of all task items,
  /// ignoring code blocks.
  static ({int done, int total}) taskCounts(String content) {
    var done = 0;
    var total = 0;
    var inFence = false;
    for (final line in content.split('\n')) {
      if (_fence.hasMatch(line)) {
        inFence = !inFence;
        continue;
      }
      if (inFence) continue;
      final match = _task.firstMatch(line);
      if (match == null) continue;
      total++;
      if (match.group(2) != ' ') done++;
    }
    return (done: done, total: total);
  }

  /// Checks or unchecks the [index]-th task item (0-based, in document
  /// order, code blocks ignored). Returns [content] unchanged if there is
  /// no such item.
  static String toggleTask(String content, int index) {
    final lines = content.split('\n');
    var seen = 0;
    var inFence = false;
    for (var i = 0; i < lines.length; i++) {
      if (_fence.hasMatch(lines[i])) {
        inFence = !inFence;
        continue;
      }
      if (inFence) continue;
      final match = _task.firstMatch(lines[i]);
      if (match == null) continue;
      if (seen++ != index) continue;
      final checked = match.group(2) != ' ';
      lines[i] = lines[i].replaceRange(
        match.start,
        match.end,
        '${match.group(1)}${checked ? ' ' : 'x'}${match.group(3)}',
      );
      return lines.join('\n');
    }
    return content;
  }
}
