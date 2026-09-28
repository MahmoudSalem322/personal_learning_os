import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// A `#tag` pill. Tappable when [onTap] is set (e.g. filter by the tag);
/// shows a remove button when [onRemove] is set (tag editors).
class TagChip extends StatelessWidget {
  const TagChip({
    required this.tag,
    super.key,
    this.onTap,
    this.onRemove,
    this.removeTooltip,
    this.selected = false,
  });

  final String tag;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? removeTooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.labelSmall!.copyWith(
      color: selected ? colors.primary : colors.mutedText,
      letterSpacing: 0,
    );
    final chip = Container(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.xs,
        end: onRemove == null ? AppSpacing.xs : 2,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: selected ? colors.primarySoft : colors.surfaceMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: selected ? colors.primary : colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '#$tag',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: AppRadius.full,
              child: Tooltip(
                message: removeTooltip ?? '',
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: AppSizes.iconSm - 2,
                    color: colors.mutedText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(onTap: onTap, borderRadius: AppRadius.chip, child: chip),
    );
  }
}
