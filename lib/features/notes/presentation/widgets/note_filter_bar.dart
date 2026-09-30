import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/filter_menu_button.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../domain/note_filter.dart';
import '../notes_providers.dart';

/// Search, filters and sort for the notes page.
class NoteFilterBar extends ConsumerStatefulWidget {
  const NoteFilterBar({required this.visibleCount, super.key});

  final int visibleCount;

  @override
  ConsumerState<NoteFilterBar> createState() => _NoteFilterBarState();
}

class _NoteFilterBarState extends ConsumerState<NoteFilterBar> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(noteFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(NoteFilter Function(NoteFilter f) change) =>
      ref.read(noteFilterProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(noteFilterProvider);
    // Global search can set the query from outside this page.
    ref.listen(noteFilterProvider.select((f) => f.query), (_, query) {
      if (_search.text != query) _search.text = query;
    });
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(noteTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => _update((f) => f.copyWith(query: v)),
                    decoration: InputDecoration(
                      hintText: l10n.notesSearchHint,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: AppSizes.iconMd,
                      ),
                      suffixIcon: filter.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.actionClearSearch,
                              icon: const Icon(
                                Icons.close_rounded,
                                size: AppSizes.iconSm,
                              ),
                              onPressed: () {
                                _search.clear();
                                _update((f) => f.copyWith(query: ''));
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Gap.sm,
            FilterMenuButton<NoteSort>(
              label: l10n.sortLabel,
              icon: Icons.sort_rounded,
              selected: filter.sort,
              highlight: false,
              options: [
                FilterOption(
                  NoteSort.recentlyUpdated,
                  l10n.sortRecentlyUpdated,
                ),
                FilterOption(
                  NoteSort.recentlyCreated,
                  l10n.sortRecentlyCreated,
                ),
                FilterOption(NoteSort.title, l10n.sortTitle),
              ],
              onSelected: (sort) {
                if (sort != null) _update((f) => f.copyWith(sort: sort));
              },
            ),
          ],
        ),
        Gap.sm,
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: AppSpacing.xs,
                  children: [
                    FilterMenuButton<String>(
                      label: l10n.filterCategory,
                      selected: filter.categoryId,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        FilterOption(
                          NoteFilter.uncategorized,
                          l10n.filterUncategorized,
                        ),
                        for (final c in categories)
                          FilterOption(
                            c.id,
                            c.name,
                            leading: CategoryAvatar(
                              icon: c.icon,
                              primaryColor: c.primaryColor,
                              secondaryColor: c.secondaryColor,
                              size: 22,
                            ),
                          ),
                      ],
                      onSelected: (id) =>
                          _update((f) => f.copyWith(categoryId: id)),
                    ),
                    if (tags.isNotEmpty || filter.tag != null)
                      FilterMenuButton<String>(
                        label: l10n.filterTag,
                        icon: Icons.tag_rounded,
                        selected: filter.tag,
                        options: [
                          FilterOption(null, l10n.filterAll),
                          for (final tag in {...tags, ?filter.tag})
                            FilterOption(tag, '#$tag'),
                        ],
                        onSelected: (tag) =>
                            _update((f) => f.copyWith(tag: tag)),
                      ),
                    FilterChip(
                      avatar: Icon(
                        filter.favoritesOnly
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: AppSizes.iconSm,
                      ),
                      label: Text(l10n.filterFavorites),
                      selected: filter.favoritesOnly,
                      showCheckmark: false,
                      onSelected: (value) =>
                          _update((f) => f.copyWith(favoritesOnly: value)),
                    ),
                    if (filter.hasFilters)
                      TextButton(
                        onPressed: () =>
                            ref.read(noteFilterProvider.notifier).reset(),
                        child: Text(l10n.resourcesClearFilters),
                      ),
                  ],
                ),
              ),
            ),
            Gap.sm,
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.notesCount(widget.visibleCount),
                style: context.textStyles.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
