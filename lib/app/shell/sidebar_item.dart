import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';

/// One navigation row in the sidebar. Icon-only (with tooltip) when
/// [expanded] is false.
class SidebarItem extends StatefulWidget {
  const SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
    super.key,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  /// Unread count shown on the icon; hidden when zero.
  final int badgeCount;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;
    final foreground = selected ? colors.primary : colors.mutedText;
    final background = selected
        ? colors.primarySoft
        : _hovered
        ? colors.hover
        : Colors.transparent;

    final content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      height: AppSizes.navItemHeight,
      padding: widget.expanded
          ? const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.navItem,
        border: Border.all(
          color: _focused ? colors.focusRing : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: widget.expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          UnreadBadge(
            count: widget.badgeCount,
            child: Icon(
              selected ? widget.selectedIcon : widget.icon,
              size: AppSizes.iconMd,
              color: foreground,
            ),
          ),
          if (widget.expanded) ...[
            Gap.sm,
            Expanded(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.label.copyWith(
                  color: selected ? colors.text : colors.mutedText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final item = Semantics(
      button: true,
      selected: selected,
      label: widget.badgeCount == 0
          ? widget.label
          : '${widget.label}, ${widget.badgeCount}',
      excludeSemantics: true,
      onTap: widget.onTap,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        onFocusChange: (value) => setState(() => _focused = value),
        borderRadius: AppRadius.navItem,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: content,
      ),
    );

    if (widget.expanded) return item;
    return Tooltip(
      message: widget.label,
      excludeFromSemantics: true,
      child: item,
    );
  }
}
