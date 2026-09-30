import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../sample_data/presentation/sample_data_actions.dart';
import '../../../sample_data/presentation/widgets/sample_data_banner.dart';
import '../../domain/task_filter.dart';
import '../task_actions.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

/// All tasks, organized into views: All, Today, Upcoming, Overdue and
/// Completed.
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tasks = ref.watch(tasksProvider);

    return AppPage(
      title: l10n.navTasks,
      subtitle: l10n.tasksSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: () => TaskActions.openForm(context),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          label: Text(l10n.tasksNew),
        ),
      ],
      body: tasks.when(
        loading: () => const _SkeletonList(),
        error: (_, _) => AppStateView.error(
          context: context,
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (all) =>
            all.isEmpty ? const _EmptyTasks() : const _TasksContent(),
      ),
    );
  }
}

class _TasksContent extends ConsumerWidget {
  const _TasksContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(taskFilterProvider);
    final visible = ref.watch(filteredTasksProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SampleDataBanner(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<TaskView>(
              showSelectedIcon: false,
              segments: [
                for (final view in TaskView.values)
                  ButtonSegment(value: view, label: Text(view.label(l10n))),
              ],
              selected: {filter.view},
              onSelectionChanged: (selection) => ref
                  .read(taskFilterProvider.notifier)
                  .update((f) => f.copyWith(view: selection.first)),
            ),
          ),
        ),
        Gap.md,
        TaskFilterBar(visibleCount: visible.length),
        Gap.md,
        Expanded(
          child: visible.isEmpty
              ? AppStateView(
                  icon: Icons.filter_list_off_rounded,
                  title: l10n.tasksNoResultsTitle,
                  message: l10n.tasksNoResultsMessage,
                  action: OutlinedButton(
                    onPressed: () => ref
                        .read(taskFilterProvider.notifier)
                        .update((f) => f.cleared().copyWith(query: '')),
                    child: Text(l10n.resourcesClearFilters),
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) => TaskCard(
                    key: ValueKey(visible[index].id),
                    task: visible[index],
                  ),
                  separatorBuilder: (_, _) => Gap.xs,
                  itemCount: visible.length,
                ),
        ),
      ],
    );
  }
}

class _EmptyTasks extends ConsumerWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppStateView(
      icon: Icons.check_circle_outline_rounded,
      title: l10n.tasksEmptyTitle,
      message: l10n.tasksEmptyMessage,
      action: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => TaskActions.openForm(context),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.tasksNew),
          ),
          OutlinedButton.icon(
            onPressed: () => SampleDataActions.load(context, ref),
            icon: const Icon(Icons.science_outlined, size: AppSizes.iconMd),
            label: Text(l10n.sampleDataLoad),
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (_, _) => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeleton(
                  width: 24,
                  height: 24,
                  borderRadius: AppRadius.chip,
                ),
                Gap.sm,
                Expanded(child: AppSkeleton(height: 16)),
                Gap.sm,
                AppSkeleton(
                  width: 32,
                  height: 24,
                  borderRadius: AppRadius.chip,
                ),
              ],
            ),
            Gap.sm,
            AppSkeleton(width: 220, height: 12),
          ],
        ),
      ),
      separatorBuilder: (_, _) => Gap.sm,
    );
  }
}
