import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:markdown/markdown.dart' as md;
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';

/// Renders Markdown with the app's design system.
///
/// Supports headings, paragraphs, bold/italic/strikethrough, inline code,
/// links, bulleted/numbered/task lists (nested), quotes, code blocks,
/// tables and rules. Task checkboxes are interactive when [onToggleTask] is
/// set; it receives the task's index in document order.
class MarkdownView extends StatefulWidget {
  const MarkdownView({
    required this.data,
    required this.onOpenLink,
    super.key,
    this.onToggleTask,
  });

  final String data;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<int>? onToggleTask;

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  late List<md.Node> _nodes = _parse(widget.data);
  final List<TapGestureRecognizer> _recognizers = [];

  static List<md.Node> _parse(String data) => md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  ).parse(data);

  @override
  void didUpdateWidget(MarkdownView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _nodes = _parse(widget.data);
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final builder = _MarkdownBuilder(
      context: context,
      onOpenLink: widget.onOpenLink,
      onToggleTask: widget.onToggleTask,
      recognizers: _recognizers,
    );
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: builder.blocks(_nodes),
      ),
    );
  }
}

/// Turns markdown AST nodes into widgets. One instance per build, so the
/// task counter matches document order.
class _MarkdownBuilder {
  _MarkdownBuilder({
    required this.context,
    required this.onOpenLink,
    required this.onToggleTask,
    required this.recognizers,
  });

  final BuildContext context;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<int>? onToggleTask;
  final List<TapGestureRecognizer> recognizers;
  int _taskIndex = 0;

  TextTheme get _text => context.textStyles;

  TextStyle get _body => _text.bodyLarge!;

  static const Set<String> _blockTags = {
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'ul',
    'ol',
    'blockquote',
    'pre',
    'hr',
    'table',
  };

  List<Widget> blocks(List<md.Node> nodes) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      final widget = _block(node);
      if (widget == null) continue;
      if (widgets.isNotEmpty) widgets.add(Gap.sm);
      widgets.add(widget);
    }
    return widgets;
  }

  Widget? _block(md.Node node) {
    if (node is md.Text) {
      final text = node.text.trim();
      return text.isEmpty ? null : Text(text, style: _body);
    }
    if (node is! md.Element) return null;
    switch (node.tag) {
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        final style = switch (node.tag) {
          'h1' => _text.headlineMedium!,
          'h2' => _text.headlineSmall!,
          'h3' => _text.titleLarge!,
          _ => _text.titleMedium!,
        };
        return Padding(
          padding: EdgeInsets.only(top: node.tag == 'h1' ? AppSpacing.xs : 4),
          child: Semantics(
            header: true,
            child: Text.rich(_inline(node.children, style)),
          ),
        );
      case 'p':
        return Text.rich(_inline(node.children, _body));
      case 'ul' || 'ol':
        return _list(node);
      case 'blockquote':
        return _quote(node);
      case 'pre':
        return _codeBlock(node);
      case 'hr':
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Divider(),
        );
      case 'table':
        return _table(node);
      default:
        return Text.rich(_inline([node], _body));
    }
  }

  Widget _list(md.Element list) {
    final ordered = list.tag == 'ol';
    final start = int.tryParse(list.attributes['start'] ?? '') ?? 1;
    final items = list.children?.whereType<md.Element>().toList() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xxs,
      children: [
        for (var i = 0; i < items.length; i++)
          _listItem(items[i], ordered ? '${start + i}.' : '•'),
      ],
    );
  }

  Widget _listItem(md.Element item, String bullet) {
    final colors = context.colors;
    var children = item.children ?? const <md.Node>[];

    // Task items: the checkbox is the first child (possibly inside a <p>).
    md.Element? checkbox;
    if (children.isNotEmpty) {
      final first = children.first;
      if (first is md.Element && first.tag == 'input') {
        checkbox = first;
        children = children.skip(1).toList();
      } else if (first is md.Element &&
          first.tag == 'p' &&
          (first.children?.isNotEmpty ?? false) &&
          first.children!.first is md.Element &&
          (first.children!.first as md.Element).tag == 'input') {
        checkbox = first.children!.first as md.Element;
        children = [
          md.Element('p', first.children!.skip(1).toList()),
          ...children.skip(1),
        ];
      }
    }

    final checked = checkbox?.attributes['checked'] == 'true';
    final taskIndex = checkbox == null ? -1 : _taskIndex++;
    final contentStyle = checked
        ? _body.copyWith(
            color: colors.mutedText,
            decoration: TextDecoration.lineThrough,
            decorationColor: colors.mutedText,
          )
        : _body;

    // Inline runs become one paragraph; nested blocks render as blocks.
    final parts = <Widget>[];
    final inlineRun = <md.Node>[];
    void flushInline() {
      if (inlineRun.isEmpty) return;
      parts.add(Text.rich(_inline(List.of(inlineRun), contentStyle)));
      inlineRun.clear();
    }

    for (final child in children) {
      if (child is md.Element && _blockTags.contains(child.tag)) {
        flushInline();
        parts.add(
          child.tag == 'p'
              ? Text.rich(_inline(child.children, contentStyle))
              : _block(child)!,
        );
      } else {
        inlineRun.add(child);
      }
    }
    flushInline();

    final marker = checkbox != null
        ? SizedBox(
            width: 28,
            height: 24,
            child: Checkbox(
              value: checked,
              onChanged: onToggleTask == null
                  ? null
                  : (_) => onToggleTask!(taskIndex),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
        : SizedBox(
            width: 24,
            child: Text(bullet, style: _body.copyWith(color: colors.mutedText)),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        marker,
        Gap.xxs,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xxs,
            children: parts,
          ),
        ),
      ],
    );
  }

  Widget _quote(md.Element quote) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: colors.primary, width: 3),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.mutedText, fontStyle: FontStyle.italic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: blocks(quote.children ?? const []),
        ),
      ),
    );
  }

  Widget _codeBlock(md.Element pre) {
    final colors = context.colors;
    final code = pre.textContent.replaceFirst(RegExp(r'\n$'), '');
    final codeElement = pre.children?.whereType<md.Element>().firstOrNull;
    final language = (codeElement?.attributes['class'] ?? '').replaceFirst(
      'language-',
      '',
    );
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.button,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.sm,
              end: AppSpacing.xxs,
            ),
            child: Row(
              children: [
                Expanded(child: Text(language, style: _text.caption)),
                IconButton(
                  tooltip: l10n.mdCopyCode,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.content_copy_rounded,
                    size: AppSizes.iconSm,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      AppToast.info(context, l10n.mdCodeCopied);
                    }
                  },
                ),
              ],
            ),
          ),
          // Code is always left-to-right, even in an Arabic UI.
          Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Text(
                code,
                style: AppTypography.mono(
                  _text.bodyMedium!.copyWith(height: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(md.Element table) {
    final colors = context.colors;
    final rows = <md.Element>[
      for (final section
          in table.children?.whereType<md.Element>() ?? const <md.Element>[])
        ...?section.children?.whereType<md.Element>(),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    final columns = rows
        .map((r) => r.children?.whereType<md.Element>().length ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(
          color: colors.border,
          borderRadius: AppRadius.chip,
        ),
        children: [
          for (final row in rows)
            TableRow(
              decoration:
                  row.children?.any((c) => c is md.Element && c.tag == 'th') ??
                      false
                  ? BoxDecoration(color: colors.surfaceMuted)
                  : null,
              children: [
                for (var i = 0; i < columns; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: () {
                      final cells =
                          row.children?.whereType<md.Element>().toList() ??
                          const [];
                      if (i >= cells.length) return const SizedBox.shrink();
                      final cell = cells[i];
                      final style = cell.tag == 'th'
                          ? _text.bodyStrong
                          : _text.body;
                      return Text.rich(_inline(cell.children, style));
                    }(),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  InlineSpan _inline(List<md.Node>? nodes, TextStyle style) {
    return TextSpan(
      style: style,
      children: [
        for (final node in nodes ?? const <md.Node>[]) _span(node, style),
      ],
    );
  }

  InlineSpan _span(md.Node node, TextStyle style) {
    final colors = context.colors;
    if (node is md.Text) return TextSpan(text: node.text);
    if (node is! md.Element) return const TextSpan();
    switch (node.tag) {
      case 'strong':
        return _inline(
          node.children,
          style.copyWith(fontWeight: FontWeight.w700),
        );
      case 'em':
        return _inline(
          node.children,
          style.copyWith(fontStyle: FontStyle.italic),
        );
      case 'del':
        return _inline(
          node.children,
          style.copyWith(decoration: TextDecoration.lineThrough),
        );
      case 'code':
        return TextSpan(
          text: node.textContent,
          style: AppTypography.mono(style).copyWith(
            fontSize: (style.fontSize ?? 16) * 0.9,
            backgroundColor: colors.surfaceMuted,
            color: colors.text,
          ),
        );
      case 'a':
        final href = node.attributes['href'] ?? '';
        final recognizer = TapGestureRecognizer()
          ..onTap = () => onOpenLink(href);
        recognizers.add(recognizer);
        return TextSpan(
          text: node.textContent,
          recognizer: recognizer,
          mouseCursor: SystemMouseCursors.click,
          style: style.copyWith(
            color: colors.primary,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary,
          ),
        );
      case 'br':
        return const TextSpan(text: '\n');
      case 'img':
        // Offline-first: images aren't fetched; the alt text stands in.
        return TextSpan(
          style: style.copyWith(color: colors.mutedText),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.image_outlined,
                size: AppSizes.iconSm,
                color: colors.mutedText,
              ),
            ),
            TextSpan(text: ' ${node.attributes['alt'] ?? ''}'),
          ],
        );
      case 'input':
        return const TextSpan();
      default:
        return _inline(node.children, style);
    }
  }
}
