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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../notes/presentation/note_actions.dart';
import '../../../notes/presentation/notes_providers.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../reminders/presentation/reminder_actions.dart';
import '../../../reminders/presentation/widgets/reminder_tile.dart';
import '../../../tags/presentation/tag_chip.dart';
import '../../../tasks/presentation/task_actions.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../domain/resource.dart';
import '../resource_actions.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';
import '../widgets/favorite_button.dart';
import '../widgets/progress_picker.dart';

/// One resource: open it, track progress, see its details.
class ResourceDetailPage extends ConsumerWidget {
  const ResourceDetailPage({required this.resourceId, super.key});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void backToList() => context.go(AppRoutes.resources);

    return ref
        .watch(resourceByIdProvider(resourceId))
        .when(
          loading: () => const _LoadingView(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(resourceByIdProvider(resourceId)),
          ),
          data: (resource) => resource == null
              ? AppStateView(
                  icon: Icons.bookmark_remove_outlined,
                  title: l10n.resourceNotFoundTitle,
                  message: l10n.resourceNotFoundMessage,
                  action: FilledButton.icon(
                    onPressed: backToList,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconMd,
                    ),
                    label: Text(l10n.resourceBackToList),
                  ),
                )
              : _ResourceView(resource: resource, onBack: backToList),
        );
  }
}

class _ResourceView extends ConsumerWidget {
  const _ResourceView({required this.resource, required this.onBack});

  final Resource resource;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = resource;
    final isMobile = context.screenSize.isMobile;

    final about = _Panel(
      title: l10n.resourceAbout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            r.description.isEmpty ? l10n.resourceNoDescription : r.description,
            style: context.textStyles.bodyLarge?.copyWith(
              color: r.description.isEmpty ? context.colors.mutedText : null,
              fontStyle: r.description.isEmpty ? FontStyle.italic : null,
            ),
          ),
          if (r.tags.isNotEmpty) ...[
            Gap.md,
            Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              children: [
                for (final tag in r.tags)
                  TagChip(
                    tag: tag,
                    onTap: () {
                      ref
                          .read(resourceFilterProvider.notifier)
                          .update((f) => f.cleared().copyWith(tag: tag));
                      context.go(AppRoutes.resources);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    final progress = _Panel(
      title: l10n.resourceFormProgress,
      child: ProgressPicker(
        value: r.progress,
        onCommitted: (value) =>
            ResourceActions.setProgress(context, ref, r, value),
      ),
    );

    final details = _Panel(
      title: l10n.resourceDetails,
      child: Column(
        children: [
          _DetailRow(
            label: l10n.resourceFormType,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.type.icon, size: AppSizes.iconSm),
                Gap.xs,
                Flexible(
                  child: Text(
                    r.type.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _DetailRow(
            label: l10n.resourceFormCategory,
            child: r.categoryId == null
                ? Text(l10n.resourceFormNoCategory)
                : CategoryChip(categoryId: r.categoryId, linked: true),
          ),
          _DetailRow(
            label: l10n.resourceFormUrl,
            child: r.hasUrl
                ? InkWell(
                    onTap: () => ResourceActions.open(context, ref, r),
                    borderRadius: AppRadius.chip,
                    child: Text(
                      UrlUtils.displayHost(r.url),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: context.colors.primary,
                      ),
                    ),
                  )
                : Text(l10n.resourceNoLink),
          ),
          _DetailRow(
            label: l10n.detailCreated,
            child: Text(context.formatDate(r.createdAt)),
          ),
          _DetailRow(
            label: l10n.detailUpdated,
            child: Text(context.formatDate(r.updatedAt)),
          ),
          _DetailRow(
            label: l10n.detailLastOpened,
            child: Text(
              r.lastOpenedAt == null
                  ? l10n.resourceNeverOpened
                  : context.formatDate(r.lastOpenedAt!),
            ),
          ),
        ],
      ),
    );

    final notes = _Panel(
      title: l10n.notesSection,
      trailing: TextButton.icon(
        onPressed: () =>
            NoteActions.createAndOpen(context, ref, resourceId: r.id),
        icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
        label: Text(l10n.notesNew),
      ),
      child: _ResourceNotes(resourceId: r.id),
    );

    final tasks = _Panel(
      title: l10n.tasksSection,
      trailing: TextButton.icon(
        onPressed: () => TaskActions.openForm(context, resourceId: r.id),
        icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
        label: Text(l10n.tasksNew),
      ),
      child: _ResourceTasks(resourceId: r.id),
    );

    final reminders = _Panel(
      title: l10n.remindersSection,
      trailing: TextButton.icon(
        onPressed: () => ReminderActions.openForm(
          context,
          target: ReminderTarget.resource,
          targetId: r.id,
          targetTitle: r.title,
        ),
        icon: const Icon(Icons.add_alarm_rounded, size: AppSizes.iconSm),
        label: Text(l10n.reminderRemindMe),
      ),
      child: ItemReminders(target: ReminderTarget.resource, targetId: r.id),
    );

    return AppPage(
      title: r.title,
      subtitle: r.hasUrl ? UrlUtils.displayHost(r.url) : r.type.label(l10n),
      backLabel: l10n.resourceBackToList,
      onBack: onBack,
      leading: ResourceTypeTile(type: r.type, size: isMobile ? 48 : 56),
      actions: [
        if (r.hasUrl)
          FilledButton.icon(
            onPressed: () => ResourceActions.open(context, ref, r),
            icon: const Icon(Icons.open_in_new_rounded, size: AppSizes.iconMd),
            label: Text(l10n.resourceOpen),
          ),
        FavoriteButton(
          isFavorite: r.isFavorite,
          onPressed: () => ResourceActions.toggleFavorite(context, ref, r),
        ),
        IconButton(
          tooltip: l10n.actionEdit,
          onPressed: () => ResourceActions.openForm(context, resource: r),
          icon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
        ),
        IconButton(
          tooltip: l10n.actionDelete,
          onPressed: () =>
              ResourceActions.delete(context, ref, r, onDeleted: onBack),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: context.colors.error,
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [about, Gap.md, notes, Gap.md, tasks],
                        ),
                      ),
                      Gap.md,
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            progress,
                            Gap.md,
                            reminders,
                            Gap.md,
                            details,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      progress,
                      Gap.md,
                      reminders,
                      Gap.md,
                      about,
                      Gap.md,
                      notes,
                      Gap.md,
                      tasks,
                      Gap.md,
                      details,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.textStyles.overline),
                ),
              ),
              ?trailing,
            ],
          ),
          Gap.sm,
          child,
        ],
      ),
    );
  }
}

/// Notes linked to the resource, newest first.
class _ResourceNotes extends ConsumerWidget {
  const _ResourceNotes({required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesByResourceProvider(resourceId)).value;
    if (notes == null) return const AppSkeleton(height: 48);
    if (notes.isEmpty) {
      return Text(
        context.l10n.notesNoneForResource,
        style: context.textStyles.caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xs,
      children: [
        for (final note in notes) NoteTile(key: ValueKey(note.id), note: note),
      ],
    );
  }
}

/// Tasks linked to the resource, most recently updated first.
class _ResourceTasks extends ConsumerWidget {
  const _ResourceTasks({required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksByResourceProvider(resourceId)).value;
    if (tasks == null) return const AppSkeleton(height: 48);
    if (tasks.isEmpty) {
      return Text(
        context.l10n.tasksNoneForResource,
        style: context.textStyles.caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xs,
      children: [
        for (final task in tasks) TaskCard(key: ValueKey(task.id), task: task),
      ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 240, height: 24),
                  Gap.xs,
                  AppSkeleton(width: 140, height: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
