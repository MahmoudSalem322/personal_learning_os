import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/tags.dart';
import 'tag_chip.dart';

/// Editable list of tags: type and press Enter (or comma/space) to add,
/// Backspace on an empty field removes the last one. Existing tags that
/// match the typed text are offered as suggestions.
class TagInput extends StatefulWidget {
  const TagInput({
    required this.tags,
    required this.onChanged,
    required this.label,
    required this.hint,
    required this.removeTooltip,
    super.key,
    this.suggestions = const [],
    this.errorText,
    this.maxTags = TagRules.maxPerItem,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String label;
  final String hint;
  final String Function(String tag) removeTooltip;
  final List<String> suggestions;
  final String? errorText;
  final int maxTags;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    // Comma or space finishes a tag, which makes pasting "a, b, c" work.
    if (text.contains(RegExp(r'[,\s]'))) {
      _add(text);
    } else {
      setState(() {});
    }
  }

  void _add(String raw) {
    final added = TagRules.parse(raw);
    _controller.clear();
    if (added.isEmpty) return;
    widget.onChanged(TagRules.normalizeAll([...widget.tags, ...added]));
    _focus.requestFocus();
  }

  void _remove(String tag) =>
      widget.onChanged(widget.tags.where((t) => t != tag).toList());

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.tags.isNotEmpty) {
      _remove(widget.tags.last);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  List<String> get _matchingSuggestions {
    final typed = TagRules.normalize(_controller.text);
    return widget.suggestions
        .where((s) => !widget.tags.contains(s))
        .where((s) => typed.isEmpty || s.contains(typed))
        .take(8)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _matchingSuggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          onKeyEvent: _onKey,
          skipTraversal: true,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            enabled: widget.tags.length < widget.maxTags,
            textInputAction: TextInputAction.done,
            onSubmitted: _add,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixText: _controller.text.isEmpty ? null : '#',
            ),
          ),
        ),
        if (widget.tags.isNotEmpty) ...[
          Gap.xs,
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final tag in widget.tags)
                TagChip(
                  tag: tag,
                  selected: true,
                  onRemove: () => _remove(tag),
                  removeTooltip: widget.removeTooltip(tag),
                ),
            ],
          ),
        ],
        if (suggestions.isNotEmpty && widget.tags.length < widget.maxTags) ...[
          Gap.xs,
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final tag in suggestions)
                TagChip(tag: tag, onTap: () => _add(tag)),
            ],
          ),
        ],
      ],
    );
  }
}
