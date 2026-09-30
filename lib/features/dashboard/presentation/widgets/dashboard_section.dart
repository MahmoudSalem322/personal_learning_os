import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

/// A titled dashboard card with an optional "View all" link.
class DashboardSection extends StatelessWidget {
  const DashboardSection({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
    this.onViewAll,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: colors.mutedText),
              Gap.xs,
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: context.textStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(context.l10n.dashboardViewAll),
                ),
            ],
          ),
          Gap.sm,
          child,
        ],
      ),
    );
  }
}

/// Muted one-line message for an empty section.
class DashboardEmptyText extends StatelessWidget {
  const DashboardEmptyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        text,
        style: context.textStyles.body.copyWith(
          color: context.colors.mutedText,
        ),
      ),
    );
  }
}

/// A tappable row inside a section: leading visual, title, subtitle and an
/// optional trailing widget.
class DashboardRow extends StatelessWidget {
  const DashboardRow({
    required this.leading,
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.chip,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            leading,
            Gap.sm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyStrong,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.caption.copyWith(
                        color: subtitleColor ?? context.colors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[Gap.xs, trailing!],
          ],
        ),
      ),
    );
  }
}
