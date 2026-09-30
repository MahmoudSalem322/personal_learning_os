import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../notes/presentation/notes_providers.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../resources/presentation/widgets/resource_grid.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../favorites_providers.dart';

/// Every starred resource, note and task in one place.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.navFavorites,
      subtitle: l10n.favoritesSubtitle,
      body: ref
          .watch(favoritesProvider)
          .when(
            loading: () => const ResourceGridSkeleton(count: 4),
            error: (_, _) => AppStateView.error(
              context: context,
              onRetry: () => ref
                ..invalidate(resourcesProvider)
                ..invalidate(notesProvider)
                ..invalidate(tasksProvider),
            ),
            data: (favorites) => _FavoritesContent(favorites: favorites),
          ),
    );
  }
}

class _FavoritesContent extends ConsumerWidget {
  const _FavoritesContent({required this.favorites});

  final Favorites favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final f = favorites;
    final total = f.resources.length + f.notes.length + f.tasks.length;
    if (total == 0) {
      return AppStateView(
        icon: Icons.star_outline_rounded,
        title: l10n.favoritesEmptyTitle,
        message: l10n.favoritesEmptyMessage,
      );
    }

    final view = ref.watch(favoritesViewProvider);
    bool shows(FavoritesView section) =>
        view == FavoritesView.all || view == section;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final (option, label, count) in [
                (FavoritesView.all, l10n.filterAll, total),
                (
                  FavoritesView.resources,
                  l10n.navResources,
                  f.resources.length,
                ),
                (FavoritesView.notes, l10n.navNotes, f.notes.length),
                (FavoritesView.tasks, l10n.navTasks, f.tasks.length),
              ])
                ChoiceChip(
                  label: Text('$label · $count'),
                  selected: view == option,
                  showCheckmark: false,
                  onSelected: (_) =>
                      ref.read(favoritesViewProvider.notifier).select(option),
                ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: Gap.lg),
        if (shows(FavoritesView.resources) && f.resources.isNotEmpty) ...[
          _Header(
            icon: Icons.collections_bookmark_outlined,
            label: l10n.navResources,
            show: view == FavoritesView.all,
          ),
          SliverResourceGrid(resources: f.resources),
          const SliverToBoxAdapter(child: Gap.xl),
        ],
        if (shows(FavoritesView.notes) && f.notes.isNotEmpty) ...[
          _Header(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.navNotes,
            show: view == FavoritesView.all,
          ),
          SliverGrid.builder(
            gridDelegate: NoteGridLayout.delegate,
            itemCount: f.notes.length,
            itemBuilder: (context, index) => NoteCard(
              key: ValueKey(f.notes[index].id),
              note: f.notes[index],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.xl),
        ],
        if (shows(FavoritesView.tasks) && f.tasks.isNotEmpty) ...[
          _Header(
            icon: Icons.check_circle_outline_rounded,
            label: l10n.navTasks,
            show: view == FavoritesView.all,
          ),
          SliverList.separated(
            itemCount: f.tasks.length,
            separatorBuilder: (_, _) => Gap.xs,
            itemBuilder: (context, index) => TaskCard(
              key: ValueKey(f.tasks[index].id),
              task: f.tasks[index],
            ),
          ),
          const SliverToBoxAdapter(child: Gap.xl),
        ],
        if (_isEmpty(view, f))
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppStateView(
              icon: Icons.star_outline_rounded,
              title: l10n.favoritesNoneOfKind,
              message: l10n.favoritesEmptyMessage,
            ),
          ),
      ],
    );
  }

  static bool _isEmpty(FavoritesView view, Favorites f) => switch (view) {
    FavoritesView.all => false,
    FavoritesView.resources => f.resources.isEmpty,
    FavoritesView.notes => f.notes.isEmpty,
    FavoritesView.tasks => f.tasks.isEmpty,
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.label, required this.show});

  final IconData icon;
  final String label;

  /// Headers only help when several kinds are listed.
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMd, color: context.colors.mutedText),
            Gap.xs,
            Semantics(
              header: true,
              child: Text(label, style: context.textStyles.subheading),
            ),
          ],
        ),
      ),
    );
  }
}
