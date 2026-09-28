import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../sample_data/presentation/sample_data_actions.dart';
import '../../../sample_data/presentation/widgets/sample_data_banner.dart';
import '../../domain/category.dart';
import '../../domain/category_service.dart';
import '../categories_providers.dart';
import '../category_actions.dart';
import '../widgets/category_card.dart';
import '../widgets/category_card_skeleton.dart';

/// All categories as a responsive grid, with filtering and creation.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider);

    return AppPage(
      title: l10n.navCategories,
      subtitle: l10n.categoriesSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: () => CategoryActions.openForm(context),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          label: Text(l10n.categoriesNew),
        ),
      ],
      body: categories.when(
        loading: () => const _SkeletonGrid(),
        error: (_, _) => AppStateView.error(
          context: context,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (all) => all.isEmpty
            ? const _EmptyState()
            : _CategoriesContent(categories: all, search: _search),
      ),
    );
  }
}

class _CategoriesContent extends StatelessWidget {
  const _CategoriesContent({required this.categories, required this.search});

  final List<Category> categories;
  final TextEditingController search;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SampleDataBanner(),
        ValueListenableBuilder(
          valueListenable: search,
          builder: (context, value, _) {
            final query = value.text;
            final visible = filterCategories(categories, query);
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Toolbar(search: search, count: visible.length),
                  Gap.md,
                  Expanded(
                    child: visible.isEmpty
                        ? AppStateView(
                            icon: Icons.search_off_rounded,
                            title: l10n.categoriesNoResultsTitle,
                            message: l10n.categoriesNoResultsMessage(
                              query.trim(),
                            ),
                          )
                        : _Grid(categories: visible),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.search, required this.count});

  final TextEditingController search;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              hintText: l10n.categoriesSearchHint,
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: AppSizes.iconMd,
              ),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.actionClearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: AppSizes.iconSm,
                      ),
                      onPressed: search.clear,
                    ),
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.categoriesCount(count),
            style: context.textStyles.caption,
          ),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverGrid.builder(
          gridDelegate: CategoryGridLayout.delegate,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(key: ValueKey(category.id), category: category);
          },
        ),
        const SliverToBoxAdapter(child: Gap.lg),
      ],
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: CategoryGridLayout.delegate,
      itemCount: 6,
      itemBuilder: (_, _) => const CategoryCardSkeleton(),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppStateView(
      icon: Icons.category_outlined,
      title: l10n.categoriesEmptyTitle,
      message: l10n.categoriesEmptyMessage,
      action: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => CategoryActions.openForm(context),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.categoriesNew),
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
