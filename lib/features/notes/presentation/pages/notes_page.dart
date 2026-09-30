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
import '../note_actions.dart';
import '../notes_providers.dart';
import '../widgets/note_card.dart';
import '../widgets/note_filter_bar.dart';

/// All notes, searchable and filterable.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notes = ref.watch(notesProvider);

    return AppPage(
      title: l10n.navNotes,
      subtitle: l10n.notesSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: () => NoteActions.createAndOpen(context, ref),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          label: Text(l10n.notesNew),
        ),
      ],
      body: notes.when(
        loading: () => const _SkeletonGrid(),
        error: (_, _) => AppStateView.error(
          context: context,
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (all) => all.every((n) => n.isBlank)
            ? const _EmptyNotes()
            : const _NotesContent(),
      ),
    );
  }
}

class _NotesContent extends ConsumerWidget {
  const _NotesContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visible = ref.watch(filteredNotesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SampleDataBanner(),
        NoteFilterBar(visibleCount: visible.length),
        Gap.md,
        Expanded(
          child: visible.isEmpty
              ? AppStateView(
                  icon: Icons.search_off_rounded,
                  title: l10n.notesNoResultsTitle,
                  message: l10n.notesNoResultsMessage,
                  action: OutlinedButton(
                    onPressed: () => ref
                        .read(noteFilterProvider.notifier)
                        .update((f) => f.cleared().copyWith(query: '')),
                    child: Text(l10n.resourcesClearFilters),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverGrid.builder(
                      gridDelegate: NoteGridLayout.delegate,
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final note = visible[index];
                        return NoteCard(key: ValueKey(note.id), note: note);
                      },
                    ),
                    const SliverToBoxAdapter(child: Gap.lg),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyNotes extends ConsumerWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppStateView(
      icon: Icons.sticky_note_2_outlined,
      title: l10n.notesEmptyTitle,
      message: l10n.notesEmptyMessage,
      action: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => NoteActions.createAndOpen(context, ref),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.notesNew),
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

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: NoteGridLayout.delegate,
      itemCount: 6,
      itemBuilder: (_, _) => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(width: 180, height: 18),
            Gap.md,
            AppSkeleton(height: 12),
            Gap.xs,
            AppSkeleton(height: 12),
            Gap.xs,
            AppSkeleton(width: 200, height: 12),
            Spacer(),
            AppSkeleton(width: 120, height: 10, borderRadius: AppRadius.chip),
          ],
        ),
      ),
    );
  }
}
