import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../resources/domain/resource_filter.dart';
import '../../../resources/presentation/resource_type_appearance.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../resources/presentation/widgets/resource_card.dart';
import '../../../resources/presentation/widgets/resource_grid.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/task_actions.dart';
import '../../../tasks/presentation/task_appearance.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../domain/dashboard_summary.dart';
import '../dashboard_providers.dart';
import 'dashboard_section.dart';

/// Started resources to pick up again, as full resource cards.
class ContinueLearningSection extends ConsumerWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resources = ref.watch(continueLearningProvider);
    return DashboardSection(
      title: l10n.dashboardContinueLearning,
      icon: Icons.play_circle_outline_rounded,
      onViewAll: resources.isEmpty
          ? null
          : () {
              ref
                  .read(resourceFilterProvider.notifier)
                  .update(
                    (f) => f.cleared().copyWith(
                      progress: ProgressFilter.inProgress,
                      sort: ResourceSort.recentlyOpened,
                    ),
                  );
              context.go(AppRoutes.resources);
            },
      child: resources.isEmpty
          ? DashboardEmptyText(l10n.dashboardContinueEmpty)
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: ResourceGridLayout.delegate,
              itemCount: resources.length,
              itemBuilder: (context, index) => ResourceCard(
                key: ValueKey(resources[index].id),
                resource: resources[index],
              ),
            ),
    );
  }
}

/// Open tasks due today, plus overdue ones, with one-tap completion.
class TodayTasksSection extends ConsumerWidget {
  const TodayTasksSection({super.key});

  static const int _shown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tasks = ref.watch(todaysTasksProvider);
    return DashboardSection(
      title: l10n.dashboardTodayTasks,
      icon: Icons.today_rounded,
      onViewAll: () {
        ref.read(taskFilterProvider.notifier).reset();
        context.go(AppRoutes.tasks);
      },
      child: tasks.isEmpty
          ? DashboardEmptyText(l10n.dashboardTodayEmpty)
          : Column(
              children: [
                for (final task in tasks.take(_shown))
                  _TaskRow(key: ValueKey(task.id), task: task),
              ],
            ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final now = DateTime.now();
    return DashboardRow(
      leading: SizedBox.square(
        dimension: 32,
        child: Checkbox(
          value: task.isCompleted,
          semanticLabel: task.title,
          onChanged: (_) => TaskActions.toggleCompleted(context, ref, task),
        ),
      ),
      title: task.title,
      subtitle: task.dueLabel(context, now),
      subtitleColor: task.isOverdue(now) ? colors.error : null,
      trailing: task.priority == TaskPriority.high
          ? Tooltip(
              message: task.priority.label(context.l10n),
              child: Icon(
                task.priority.icon,
                size: AppSizes.iconSm,
                color: colors.error,
              ),
            )
          : null,
      onTap: () => context.go(AppRoutes.task(task.id)),
    );
  }
}

/// Progress of each category that has resources.
class LearningProgressSection extends ConsumerWidget {
  const LearningProgressSection({super.key});

  static const int _shown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(categoryProgressListProvider);
    return DashboardSection(
      title: l10n.dashboardProgress,
      icon: Icons.insights_rounded,
      onViewAll: () => context.go(AppRoutes.categories),
      child: items.isEmpty
          ? DashboardEmptyText(l10n.dashboardProgressEmpty)
          : Column(
              children: [
                for (final item in items.take(_shown))
                  _ProgressRow(key: ValueKey(item.category.id), item: item),
              ],
            ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item, super.key});

  final CategoryProgress item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final c = item.category;
    final percent = item.progress.percent ?? 0;
    return InkWell(
      onTap: () => context.go(AppRoutes.category(c.id)),
      borderRadius: AppRadius.chip,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            CategoryAvatar(
              icon: c.icon,
              primaryColor: c.primaryColor,
              secondaryColor: c.secondaryColor,
              size: 32,
            ),
            Gap.sm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyStrong,
                        ),
                      ),
                      Gap.xs,
                      Text(
                        l10n.progressPercent(percent),
                        style: text.caption.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Gap.xxs,
                  AppProgressBar(percent: percent, height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Newest resources.
class RecentResourcesSection extends ConsumerWidget {
  const RecentResourcesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resources = ref.watch(recentResourcesProvider);
    return DashboardSection(
      title: l10n.dashboardRecentResources,
      icon: Icons.schedule_rounded,
      onViewAll: () {
        ref
            .read(resourceFilterProvider.notifier)
            .update(
              (f) => f.cleared().copyWith(sort: ResourceSort.recentlyAdded),
            );
        context.go(AppRoutes.resources);
      },
      child: resources.isEmpty
          ? DashboardEmptyText(l10n.dashboardRecentEmpty)
          : Column(
              children: [
                for (final r in resources)
                  DashboardRow(
                    key: ValueKey(r.id),
                    leading: ResourceTypeTile(type: r.type, size: 32),
                    title: r.title,
                    subtitle: r.hasUrl
                        ? UrlUtils.displayHost(r.url)
                        : r.type.label(l10n),
                    trailing: Text(
                      context.formatDate(r.createdAt),
                      style: context.textStyles.caption,
                    ),
                    onTap: () => context.go(AppRoutes.resource(r.id)),
                  ),
              ],
            ),
    );
  }
}

/// Starred resources, notes and tasks.
class FavoritesSection extends ConsumerWidget {
  const FavoritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(favoritesPreviewProvider);
    return DashboardSection(
      title: l10n.dashboardFavorites,
      icon: Icons.star_outline_rounded,
      child: items.isEmpty
          ? DashboardEmptyText(l10n.dashboardFavoritesEmpty)
          : Column(
              children: [
                for (final item in items)
                  switch (item) {
                    FavoriteResource(:final resource) => DashboardRow(
                      key: ValueKey('resource-${resource.id}'),
                      leading: ResourceTypeTile(type: resource.type, size: 32),
                      title: resource.title,
                      subtitle: l10n.quickAddResource,
                      onTap: () => context.go(AppRoutes.resource(resource.id)),
                    ),
                    FavoriteNote(:final note) => DashboardRow(
                      key: ValueKey('note-${note.id}'),
                      leading: const AppIconTile(
                        icon: Icons.sticky_note_2_outlined,
                      ),
                      title: note.title.isEmpty
                          ? l10n.noteUntitled
                          : note.title,
                      subtitle: l10n.quickAddNote,
                      onTap: () => context.go(AppRoutes.note(note.id)),
                    ),
                    FavoriteTask(:final task) => DashboardRow(
                      key: ValueKey('task-${task.id}'),
                      leading: AppIconTile(icon: task.status.icon),
                      title: task.title,
                      subtitle: l10n.quickAddTask,
                      onTap: () => context.go(AppRoutes.task(task.id)),
                    ),
                  },
              ],
            ),
    );
  }
}
