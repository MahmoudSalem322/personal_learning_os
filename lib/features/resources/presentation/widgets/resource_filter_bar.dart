import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/filter_menu_button.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../domain/resource.dart';
import '../../domain/resource_filter.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';

/// Search, filters and sort for the resources page.
class ResourceFilterBar extends ConsumerStatefulWidget {
  const ResourceFilterBar({required this.visibleCount, super.key});

  final int visibleCount;

  @override
  ConsumerState<ResourceFilterBar> createState() => _ResourceFilterBarState();
}

class _ResourceFilterBarState extends ConsumerState<ResourceFilterBar> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(resourceFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(ResourceFilter Function(ResourceFilter f) change) =>
      ref.read(resourceFilterProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(resourceFilterProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(allTagsProvider);

    final sortLabels = {
      ResourceSort.recentlyAdded: l10n.sortRecentlyAdded,
      ResourceSort.recentlyOpened: l10n.sortRecentlyOpened,
      ResourceSort.title: l10n.sortTitle,
      ResourceSort.progress: l10n.sortProgress,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextField(
                    controller: _search,
                    onChanged: (value) =>
                        _update((f) => f.copyWith(query: value)),
                    decoration: InputDecoration(
                      hintText: l10n.resourcesSearchHint,
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
            FilterMenuButton<ResourceSort>(
              label: l10n.sortLabel,
              icon: Icons.sort_rounded,
              selected: filter.sort,
              highlight: false,
              options: [
                for (final sort in ResourceSort.values)
                  FilterOption(sort, sortLabels[sort]!),
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
                    FilterMenuButton<ResourceType>(
                      label: l10n.filterType,
                      selected: filter.type,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        for (final type in ResourceType.values)
                          FilterOption(
                            type,
                            type.label(l10n),
                            leading: Icon(type.icon, size: AppSizes.iconMd),
                          ),
                      ],
                      onSelected: (type) =>
                          _update((f) => f.copyWith(type: type)),
                    ),
                    FilterMenuButton<String>(
                      label: l10n.filterCategory,
                      selected: filter.categoryId,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        FilterOption(
                          ResourceFilter.uncategorized,
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
                    FilterMenuButton<ProgressFilter>(
                      label: l10n.filterProgress,
                      selected: filter.progress == ProgressFilter.all
                          ? null
                          : filter.progress,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        FilterOption(
                          ProgressFilter.notStarted,
                          l10n.progressNotStarted,
                        ),
                        FilterOption(
                          ProgressFilter.inProgress,
                          l10n.progressInProgress,
                        ),
                        FilterOption(
                          ProgressFilter.completed,
                          l10n.progressCompleted,
                        ),
                      ],
                      onSelected: (p) => _update(
                        (f) => f.copyWith(progress: p ?? ProgressFilter.all),
                      ),
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
                            ref.read(resourceFilterProvider.notifier).reset(),
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
                l10n.resourcesCount(widget.visibleCount),
                style: context.textStyles.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
