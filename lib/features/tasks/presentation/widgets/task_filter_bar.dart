import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/filter_menu_button.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../domain/task.dart';
import '../../domain/task_filter.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';

/// Search, filters and sort for the tasks page. The [TaskView] tabs live
/// above this bar.
class TaskFilterBar extends ConsumerStatefulWidget {
  const TaskFilterBar({required this.visibleCount, super.key});

  final int visibleCount;

  @override
  ConsumerState<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends ConsumerState<TaskFilterBar> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(taskFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(TaskFilter Function(TaskFilter f) change) =>
      ref.read(taskFilterProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(taskFilterProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(taskTagsProvider);

    final sortLabels = {
      TaskSort.dueDate: l10n.sortDueDate,
      TaskSort.priority: l10n.sortPriority,
      TaskSort.recentlyCreated: l10n.sortRecentlyCreated,
      TaskSort.recentlyUpdated: l10n.sortRecentlyUpdated,
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
                      hintText: l10n.tasksSearchHint,
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
            FilterMenuButton<TaskSort>(
              label: l10n.sortLabel,
              icon: Icons.sort_rounded,
              selected: filter.sort,
              highlight: false,
              options: [
                for (final sort in TaskSort.values)
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
                    FilterMenuButton<TaskStatus>(
                      label: l10n.filterStatus,
                      selected: filter.status,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        for (final status in TaskStatus.values)
                          FilterOption(status, status.label(l10n)),
                      ],
                      onSelected: (status) =>
                          _update((f) => f.copyWith(status: status)),
                    ),
                    FilterMenuButton<TaskPriority>(
                      label: l10n.filterPriority,
                      selected: filter.priority,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        for (final priority in TaskPriority.values)
                          FilterOption(priority, priority.label(l10n)),
                      ],
                      onSelected: (priority) =>
                          _update((f) => f.copyWith(priority: priority)),
                    ),
                    FilterMenuButton<String>(
                      label: l10n.filterCategory,
                      selected: filter.categoryId,
                      options: [
                        FilterOption(null, l10n.filterAll),
                        FilterOption(
                          TaskFilter.uncategorized,
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
                            ref.read(taskFilterProvider.notifier).reset(),
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
                l10n.tasksCount(widget.visibleCount),
                style: context.textStyles.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
