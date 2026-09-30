import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../resources/presentation/widgets/favorite_button.dart';
import '../../../resources/presentation/widgets/resource_chip.dart';
import '../../../tags/presentation/tag_chip.dart';
import '../../domain/task.dart';
import '../task_actions.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';
import 'task_menu_button.dart';

/// Row card for a task: checkbox, title, priority and status badges, due
/// date (red when overdue), category and resource chips. Clicking opens
/// the task page.
class TaskCard extends ConsumerWidget {
  const TaskCard({required this.task, super.key});

  final Task task;

  void _filterByTag(BuildContext context, WidgetRef ref, String tag) {
    ref
        .read(taskFilterProvider.notifier)
        .update((f) => f.cleared().copyWith(tag: tag));
    context.go(AppRoutes.tasks);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final t = task;

    final due = t.dueDate;
    final now = DateTime.now();
    final overdue = t.isOverdue(now);
    final activeTag = ref.watch(taskFilterProvider.select((f) => f.tag));

    return AppCard(
      onTap: () => context.go(AppRoutes.task(t.id)),
      semanticLabel: t.title,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppSizes.iconLg,
                child: Checkbox(
                  value: t.isCompleted,
                  semanticLabel: t.title,
                  // Tapping the card opens the page; the checkbox stops here.
                  onChanged: (_) =>
                      TaskActions.toggleCompleted(context, ref, t),
                ),
              ),
              Gap.sm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyStrong.copyWith(
                        color: t.isCompleted ? colors.mutedText : null,
                        decoration: t.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (t.description.isNotEmpty) ...[
                      Gap.xxs,
                      Text(
                        t.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.caption.copyWith(color: colors.mutedText),
                      ),
                    ],
                  ],
                ),
              ),
              Gap.xs,
              FavoriteButton(
                isFavorite: t.isFavorite,
                onPressed: () => TaskActions.toggleFavorite(context, ref, t),
              ),
              TaskMenuButton(task: t),
            ],
          ),
          Gap.xs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TaskPriorityBadge(priority: t.priority),
              TaskStatusBadge(status: t.status),
              if (due != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      overdue ? Icons.event_busy_rounded : Icons.event_outlined,
                      size: AppSizes.iconSm,
                      color: overdue ? colors.error : colors.mutedText,
                    ),
                    Gap.xxs,
                    Text(
                      t.dueLabel(context, now),
                      style: text.caption.copyWith(
                        color: overdue ? colors.error : colors.mutedText,
                        fontWeight: overdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              if (t.categoryId != null) CategoryChip(categoryId: t.categoryId),
              if (t.resourceId != null) ResourceChip(resourceId: t.resourceId),
              for (final tag in t.tags)
                TagChip(
                  tag: tag,
                  selected: tag == activeTag,
                  onTap: () => _filterByTag(context, ref, tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
