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
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../notes/presentation/note_actions.dart';
import '../../../notes/presentation/notes_providers.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../resources/domain/learning_progress.dart';
import '../../../resources/presentation/resource_actions.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../resources/presentation/widgets/resource_grid.dart';
import '../../../tasks/presentation/task_actions.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../domain/category.dart';
import '../categories_providers.dart';
import '../category_actions.dart';
import '../widgets/category_avatar.dart';

/// A single category: identity, metadata and (in later phases) its
/// resources, notes and tasks.
class CategoryDetailPage extends ConsumerWidget {
  const CategoryDetailPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void backToList() => context.go(AppRoutes.categories);

    return ref
        .watch(categoryByIdProvider(categoryId))
        .when(
          loading: () => const _LoadingView(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(categoryByIdProvider(categoryId)),
          ),
          data: (category) => category == null
              ? AppStateView(
                  icon: Icons.category_outlined,
                  title: l10n.categoryNotFoundTitle,
                  message: l10n.categoryNotFoundMessage,
                  action: FilledButton.icon(
                    onPressed: backToList,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconMd,
                    ),
                    label: Text(l10n.categoryBackToList),
                  ),
                )
              : _CategoryView(category: category, onBack: backToList),
        );
  }
}

class _CategoryView extends ConsumerWidget {
  const _CategoryView({required this.category, required this.onBack});

  final Category category;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isMobile = context.screenSize.isMobile;

    return AppPage(
      title: category.name,
      subtitle: category.description,
      backLabel: l10n.categoryBackToList,
      onBack: onBack,
      leading: CategoryAvatar(
        icon: category.icon,
        primaryColor: category.primaryColor,
        secondaryColor: category.secondaryColor,
        size: isMobile ? 48 : 56,
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () =>
              CategoryActions.openForm(context, category: category),
          icon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
          label: Text(l10n.actionEdit),
        ),
        IconButton(
          tooltip: l10n.actionDelete,
          onPressed: () =>
              CategoryActions.delete(context, ref, category, onDeleted: onBack),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: context.colors.error,
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: l10n.dateCreatedOn(
                    context.formatDate(category.createdAt),
                  ),
                ),
                _MetaChip(
                  icon: Icons.update_rounded,
                  label: l10n.dateUpdatedOn(
                    context.formatDate(category.updatedAt),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.lg),
          SliverToBoxAdapter(child: _Stats(categoryId: category.id)),
          const SliverToBoxAdapter(child: Gap.xl),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.categoryResourcesSection,
                      style: context.textStyles.subheading,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => ResourceActions.openForm(
                    context,
                    categoryId: category.id,
                  ),
                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
                  label: Text(l10n.resourcesNew),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.md),
          _CategoryResources(category: category),
          const SliverToBoxAdapter(child: Gap.xl),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.notesSection,
                      style: context.textStyles.subheading,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => NoteActions.createAndOpen(
                    context,
                    ref,
                    categoryId: category.id,
                  ),
                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
                  label: Text(l10n.notesNew),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.md),
          _CategoryNotes(category: category),
          const SliverToBoxAdapter(child: Gap.xl),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.tasksSection,
                      style: context.textStyles.subheading,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      TaskActions.openForm(context, categoryId: category.id),
                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
                  label: Text(l10n.tasksNew),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.md),
          _CategoryTasks(category: category),
          const SliverToBoxAdapter(child: Gap.lg),
        ],
      ),
    );
  }
}

/// Resource count, completed count and overall progress of a category.
class _Stats extends ConsumerWidget {
  const _Stats({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(
      categoryProgressProvider.select(
        (all) => all[categoryId] ?? LearningProgress.empty,
      ),
    );
    // Equal-height tiles even though only one has a progress bar.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Expanded(
            child: _StatTile(
              label: l10n.categoryStatResources,
              value: '${progress.resourceCount}',
            ),
          ),
          Expanded(
            child: _StatTile(
              label: l10n.categoryStatCompleted,
              value: '${progress.completedCount}',
            ),
          ),
          Expanded(
            child: _StatTile(
              label: l10n.categoryStatProgress,
              value: progress.percent == null
                  ? '—'
                  : l10n.progressPercent(progress.percent!),
              footer: AppProgressBar(percent: progress.percent ?? 0, height: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.footer});

  final String label;
  final String value;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap.xxs,
          Text(
            value,
            style: text.subheading.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (footer != null) ...[Gap.xs, footer!],
        ],
      ),
    );
  }
}

class _CategoryTasks extends ConsumerWidget {
  const _CategoryTasks({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tasks = ref.watch(tasksByCategoryProvider(category.id)).value;
    if (tasks == null) {
      return const SliverToBoxAdapter(child: AppSkeleton(height: 56));
    }
    if (tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: AppCard(
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: AppSizes.iconMd,
                color: context.colors.mutedText,
              ),
              Gap.sm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tasksNoneForCategory(category.name),
                      style: context.textStyles.bodyStrong,
                    ),
                    Text(
                      l10n.tasksNoneMessage,
                      style: context.textStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, _) => Gap.xs,
      itemBuilder: (context, index) =>
          TaskCard(key: ValueKey(tasks[index].id), task: tasks[index]),
    );
  }
}

class _CategoryNotes extends ConsumerWidget {
  const _CategoryNotes({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notes = ref.watch(notesByCategoryProvider(category.id)).value;
    if (notes == null) {
      return const SliverToBoxAdapter(child: AppSkeleton(height: 56));
    }
    if (notes.isEmpty) {
      return SliverToBoxAdapter(
        child: AppCard(
          child: Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: AppSizes.iconMd,
                color: context.colors.mutedText,
              ),
              Gap.sm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notesNoneForCategory(category.name),
                      style: context.textStyles.bodyStrong,
                    ),
                    Text(
                      l10n.notesNoneMessage,
                      style: context.textStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.separated(
      itemCount: notes.length,
      separatorBuilder: (_, _) => Gap.xs,
      itemBuilder: (context, index) =>
          NoteTile(key: ValueKey(notes[index].id), note: notes[index]),
    );
  }
}

class _CategoryResources extends ConsumerWidget {
  const _CategoryResources({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resources = ref.watch(resourcesByCategoryProvider(category.id));
    return resources.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(height: 220, child: ResourceGridSkeleton(count: 2)),
      ),
      error: (_, _) => SliverToBoxAdapter(
        child: SizedBox(
          height: 280,
          child: AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(resourcesProvider),
          ),
        ),
      ),
      data: (list) => list.isEmpty
          ? SliverToBoxAdapter(
              child: AppCard(
                child: SizedBox(
                  height: 280,
                  child: AppStateView(
                    icon: Icons.collections_bookmark_outlined,
                    title: l10n.categoryNoResourcesTitle(category.name),
                    message: l10n.categoryNoResourcesMessage,
                    action: FilledButton.icon(
                      onPressed: () => ResourceActions.openForm(
                        context,
                        categoryId: category.id,
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: AppSizes.iconMd,
                      ),
                      label: Text(l10n.resourcesNew),
                    ),
                  ),
                ),
              ),
            )
          : SliverResourceGrid(resources: list, showCategory: false),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: colors.mutedText),
          Gap.xs,
          Text(label, style: context.textStyles.caption),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 200, height: 24),
                  Gap.xs,
                  AppSkeleton(width: 280, height: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
