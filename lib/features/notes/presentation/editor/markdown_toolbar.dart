import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import 'markdown_editing.dart';

/// Formatting buttons for the Markdown editor. Every button edits
/// [controller] through [MarkdownEditing] and hands focus back to the text.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    required this.controller,
    required this.focusNode,
    required this.onEdited,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Called after the toolbar changed the text (to schedule a save).
  final VoidCallback onEdited;

  void _apply(TextEditingValue Function(TextEditingValue) edit) {
    controller.value = edit(controller.value);
    focusNode.requestFocus();
    onEdited();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget button(IconData icon, String tooltip, VoidCallback onPressed) =>
        IconButton(
          tooltip: tooltip,
          icon: Icon(icon, size: AppSizes.iconMd),
          onPressed: onPressed,
        );

    Widget divider() => const SizedBox(
      height: 24,
      child: VerticalDivider(width: AppSpacing.md),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          MenuAnchor(
            menuChildren: [
              for (final (block, label) in [
                (MarkdownBlock.heading1, l10n.mdHeading1),
                (MarkdownBlock.heading2, l10n.mdHeading2),
                (MarkdownBlock.heading3, l10n.mdHeading3),
              ])
                MenuItemButton(
                  onPressed: () =>
                      _apply((v) => MarkdownEditing.toggleBlock(v, block)),
                  child: Text(label),
                ),
            ],
            builder: (context, menu, _) => button(
              Icons.title_rounded,
              l10n.mdHeading,
              () => menu.isOpen ? menu.close() : menu.open(),
            ),
          ),
          button(
            Icons.format_bold_rounded,
            l10n.mdBold,
            () => _apply((v) => MarkdownEditing.toggleInline(v, '**')),
          ),
          button(
            Icons.format_italic_rounded,
            l10n.mdItalic,
            () => _apply((v) => MarkdownEditing.toggleInline(v, '_')),
          ),
          button(
            Icons.code_rounded,
            l10n.mdInlineCode,
            () => _apply((v) => MarkdownEditing.toggleInline(v, '`')),
          ),
          divider(),
          button(
            Icons.format_list_bulleted_rounded,
            l10n.mdBulletList,
            () => _apply(
              (v) => MarkdownEditing.toggleBlock(v, MarkdownBlock.bullet),
            ),
          ),
          button(
            Icons.format_list_numbered_rounded,
            l10n.mdNumberedList,
            () => _apply(
              (v) => MarkdownEditing.toggleBlock(v, MarkdownBlock.numbered),
            ),
          ),
          button(
            Icons.checklist_rounded,
            l10n.mdChecklist,
            () => _apply(
              (v) => MarkdownEditing.toggleBlock(v, MarkdownBlock.task),
            ),
          ),
          button(
            Icons.format_quote_rounded,
            l10n.mdQuote,
            () => _apply(
              (v) => MarkdownEditing.toggleBlock(v, MarkdownBlock.quote),
            ),
          ),
          divider(),
          button(
            Icons.data_object_rounded,
            l10n.mdCodeBlock,
            () => _apply(MarkdownEditing.insertCodeBlock),
          ),
          button(
            Icons.link_rounded,
            l10n.mdLink,
            () => _apply(MarkdownEditing.insertLink),
          ),
        ],
      ),
    );
  }
}
