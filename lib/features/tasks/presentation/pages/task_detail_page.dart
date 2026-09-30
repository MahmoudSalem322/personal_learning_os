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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../resources/presentation/widgets/favorite_button.dart';
import '../../../resources/presentation/widgets/resource_chip.dart';
import '../../domain/task.dart';
import '../task_actions.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';

/// One task: its status, schedule and links.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void backToList() => context.go(AppRoutes.tasks);

    return ref
        .watch(taskByIdProvider(taskId))
        .when(
          loading: () => const _LoadingView(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(taskByIdProvider(taskId)),
          ),
          data: (task) => task == null
              ? AppStateView(
                  icon: Icons.check_circle_outline_rounded,
                  title: l10n.taskNotFoundTitle,
                  message: l10n.taskNotFoundMessage,
                  action: FilledButton.icon(
                    onPressed: backToList,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconMd,
                    ),
                    label: Text(l10n.taskBackToList),
                  ),
                )
              : _TaskView(task: task, onBack: backToList),
        );
  }
}

class _TaskView extends ConsumerWidget {
  const _TaskView({required this.task, required this.onBack});

  final Task task;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final t = task;
    final due = t.dueDate;
    final overdue = t.isOverdue(DateTime.now());

    final details = AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.resourceDetails, style: text.overline),
          ),
          Gap.sm,
          _DetailRow(
            label: l10n.filterPriority,
            child: TaskPriorityBadge(priority: t.priority),
          ),
          _DetailRow(
            label: l10n.filterStatus,
            child: TaskStatusBadge(status: t.status),
          ),
          _DetailRow(
            label: l10n.taskFormDueDate,
            child: due == null
                ? Text(l10n.taskFormNoDueDate)
                : Text(
                    context.formatDate(due),
                    style: overdue
                        ? text.body.copyWith(color: colors.error)
                        : null,
                  ),
          ),
          _DetailRow(
            label: l10n.resourceFormCategory,
            child: t.categoryId == null
                ? Text(l10n.resourceFormNoCategory)
                : CategoryChip(categoryId: t.categoryId, linked: true),
          ),
          _DetailRow(
            label: l10n.noteResource,
            child: t.resourceId == null
                ? Text(l10n.noteNoResource)
                : ResourceChip(resourceId: t.resourceId, linked: true),
          ),
          _DetailRow(
            label: l10n.detailCreated,
            child: Text(context.formatDate(t.createdAt)),
          ),
          _DetailRow(
            label: l10n.detailUpdated,
            child: Text(context.formatDate(t.updatedAt)),
          ),
          if (t.completedAt != null)
            _DetailRow(
              label: l10n.taskCompletedOn,
              child: Text(context.formatDate(t.completedAt!)),
            ),
        ],
      ),
    );

    return AppPage(
      title: t.title,
      backLabel: l10n.taskBackToList,
      onBack: onBack,
      leading: _StatusTile(status: t.status, size: 56),
      actions: [
        SegmentedButton<TaskStatus>(
          showSelectedIcon: false,
          segments: [
            for (final status in TaskStatus.values)
              ButtonSegment(
                value: status,
                icon: Icon(status.icon, size: AppSizes.iconSm),
                label: context.screenSize.isMobile
                    ? null
                    : Text(status.label(l10n)),
                tooltip: status.label(l10n),
              ),
          ],
          selected: {t.status},
          onSelectionChanged: (selection) =>
              TaskActions.setStatus(context, ref, t, selection.first),
        ),
        FavoriteButton(
          isFavorite: t.isFavorite,
          onPressed: () => TaskActions.toggleFavorite(context, ref, t),
        ),
        IconButton(
          tooltip: l10n.actionEdit,
          onPressed: () => TaskActions.openForm(context, task: t),
          icon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
        ),
        IconButton(
          tooltip: l10n.actionDelete,
          onPressed: () =>
              TaskActions.delete(context, ref, t, onDeleted: onBack),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: colors.error,
          ),
        ),
      ],
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (t.description.isNotEmpty) ...[
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SelectableText(t.description, style: text.bodyLarge),
                  ),
                  Gap.md,
                ],
                details,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round status tile leading the page title.
class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.size});

  final TaskStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (foreground, background) = switch (status) {
      TaskStatus.todo => (colors.mutedText, colors.surfaceMuted),
      TaskStatus.inProgress => (colors.info, colors.infoSoft),
      TaskStatus.completed => (colors.success, colors.successSoft),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(status.icon, size: AppSizes.iconLg, color: foreground),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: context.textStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                style: context.textStyles.body,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPage.paddingFor(context.screenSize),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: 110, height: 14),
          Gap.lg,
          Row(
            children: [
              AppSkeleton(width: 56, height: 56, borderRadius: AppRadius.card),
              Gap.md,
              AppSkeleton(width: 240, height: 24),
            ],
          ),
          Gap.lg,
          AppSkeleton(height: 120, borderRadius: AppRadius.card),
        ],
      ),
    );
  }
}
