import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'global_search_dialog.dart';

/// Opens global search on Ctrl+K / ⌘K from anywhere in [child], unless
/// another dialog is on top.
class GlobalSearchShortcut extends StatefulWidget {
  const GlobalSearchShortcut({required this.child, super.key});

  final Widget child;

  @override
  State<GlobalSearchShortcut> createState() => _GlobalSearchShortcutState();
}

class _GlobalSearchShortcutState extends State<GlobalSearchShortcut> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyK) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return false;
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return false;
    showGlobalSearch(context);
    // web/index.html stops the browser's own Ctrl+K shortcut.
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Search entry point for the sidebar: a field-like button with the
/// shortcut, or an icon when [expanded] is false.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({required this.expanded, super.key});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final shortcut = searchShortcutLabel();
    final tooltip = l10n.searchTooltip(shortcut);

    if (!expanded) {
      return IconButton(
        tooltip: tooltip,
        onPressed: () => showGlobalSearch(context),
        icon: const Icon(Icons.search_rounded, size: AppSizes.iconMd),
      );
    }
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.input,
        child: InkWell(
          onTap: () => showGlobalSearch(context),
          borderRadius: AppRadius.input,
          child: Container(
            height: AppSizes.navItemHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.input,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: AppSizes.iconMd,
                  color: colors.mutedText,
                ),
                Gap.xs,
                Expanded(
                  child: Text(
                    l10n.searchButton,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.body.copyWith(
                      color: colors.mutedText,
                    ),
                  ),
                ),
                KeyCap(label: shortcut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
