import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// One choice in a [FilterMenuButton].
class FilterOption<T> {
  const FilterOption(this.value, this.label, {this.leading});

  /// `null` means "all" (no filter).
  final T? value;
  final String label;
  final Widget? leading;
}

/// Compact dropdown for list filters: shows "Label: Value" and highlights
/// itself while a non-default option is selected.
class FilterMenuButton<T> extends StatelessWidget {
  const FilterMenuButton({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
    this.icon,
    this.highlight = true,
  });

  final String label;
  final List<FilterOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final IconData? icon;

  /// Whether a selected value colors the button as an active filter. Off
  /// for choices that always have a value, like sort order.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = selected != null;
    final active = hasValue && highlight;
    final current = options.firstWhere(
      (o) => o.value == selected,
      orElse: () => options.first,
    );

    return MenuAnchor(
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            leadingIcon: option.leading,
            trailingIcon: option.value == selected
                ? Icon(
                    Icons.check_rounded,
                    size: AppSizes.iconMd,
                    color: colors.primary,
                  )
                : null,
            onPressed: () => onSelected(option.value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
      builder: (context, controller, _) => OutlinedButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          backgroundColor: active ? colors.primarySoft : null,
          foregroundColor: active ? colors.primary : colors.text,
          side: BorderSide(color: active ? colors.primary : colors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: AppSizes.iconSm), Gap.xs],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                !hasValue
                    ? label
                    : highlight
                    ? '$label: ${current.label}'
                    : current.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Gap.xxs,
            Icon(
              Icons.expand_more_rounded,
              size: AppSizes.iconSm,
              color: active ? colors.primary : colors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
