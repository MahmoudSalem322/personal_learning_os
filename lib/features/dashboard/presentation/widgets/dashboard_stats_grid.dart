import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../tasks/domain/task_filter.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../domain/dashboard_summary.dart';

/// The six dashboard totals. Each tile opens the matching page.
class DashboardStatsGrid extends ConsumerWidget {
  const DashboardStatsGrid({required this.stats, super.key});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;

    void openTasks(TaskView view) {
      ref
          .read(taskFilterProvider.notifier)
          .update((f) => f.cleared().copyWith(view: view));
      context.go(AppRoutes.tasks);
    }

    final progress = stats.overallProgress;
    final tiles = [
      _StatTile(
        icon: Icons.collections_bookmark_outlined,
        tint: colors.primary,
        label: l10n.dashboardStatResources,
        value: '${stats.resources}',
        onTap: () => context.go(AppRoutes.resources),
      ),
      _StatTile(
        icon: Icons.sticky_note_2_outlined,
        tint: colors.secondary,
        label: l10n.dashboardStatNotes,
        value: '${stats.notes}',
        onTap: () => context.go(AppRoutes.notes),
      ),
      _StatTile(
        icon: Icons.pending_actions_rounded,
        tint: colors.warning,
        label: l10n.dashboardStatPendingTasks,
        value: '${stats.pendingTasks}',
        onTap: () => openTasks(TaskView.all),
      ),
      _StatTile(
        icon: Icons.task_alt_rounded,
        tint: colors.success,
        label: l10n.dashboardStatCompletedTasks,
        value: '${stats.completedTasks}',
        onTap: () => openTasks(TaskView.completed),
      ),
      _StatTile(
        icon: Icons.category_outlined,
        tint: colors.info,
        label: l10n.dashboardStatCategories,
        value: '${stats.categories}',
        onTap: () => context.go(AppRoutes.categories),
      ),
      _StatTile(
        icon: Icons.trending_up_rounded,
        tint: colors.primary,
        label: l10n.dashboardStatProgress,
        value: progress == null ? '—' : l10n.progressPercent(progress),
        footer: AppProgressBar(percent: progress ?? 0, height: 4),
      ),
    ];

    return _TileGrid(children: tiles);
  }
}

/// Loading placeholder shaped like [DashboardStatsGrid].
class DashboardStatsSkeleton extends StatelessWidget {
  const DashboardStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _TileGrid(
      children: List.generate(
        6,
        (_) => const AppSkeleton(height: 104, borderRadius: AppRadius.card),
      ),
    );
  }
}

/// Six equal tiles: 6 per row on wide screens, 3 on medium, 2 on phones.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 960
            ? 6
            : width >= 520
            ? 3
            : 2;
        const spacing = AppSpacing.sm;
        final tileWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.footer,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return AppCard(
      onTap: onTap,
      semanticLabel: '$label: $value',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSizes.iconSm, color: tint),
                Gap.xs,
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.caption,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: text.subheading.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (footer != null) ...[Gap.xxs, footer!],
          ],
        ),
      ),
    );
  }
}
