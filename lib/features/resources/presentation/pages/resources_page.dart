import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../sample_data/presentation/sample_data_actions.dart';
import '../../../sample_data/presentation/widgets/sample_data_banner.dart';
import '../resource_actions.dart';
import '../resources_providers.dart';
import '../widgets/resource_filter_bar.dart';
import '../widgets/resource_grid.dart';

/// The learning library: every resource, searchable and filterable.
class ResourcesPage extends ConsumerWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resources = ref.watch(resourcesProvider);

    return AppPage(
      title: l10n.navResources,
      subtitle: l10n.resourcesSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: () => ResourceActions.openForm(context),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          label: Text(l10n.resourcesNew),
        ),
      ],
      body: resources.when(
        loading: () => const ResourceGridSkeleton(),
        error: (_, _) => AppStateView.error(
          context: context,
          onRetry: () => ref.invalidate(resourcesProvider),
        ),
        data: (all) =>
            all.isEmpty ? const _EmptyLibrary() : const _LibraryContent(),
      ),
    );
  }
}

class _LibraryContent extends ConsumerWidget {
  const _LibraryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visible = ref.watch(filteredResourcesProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SampleDataBanner(),
        ResourceFilterBar(visibleCount: visible.length),
        Gap.md,
        Expanded(
          child: visible.isEmpty
              ? AppStateView(
                  icon: Icons.search_off_rounded,
                  title: l10n.resourcesNoResultsTitle,
                  message: l10n.resourcesNoResultsMessage,
                  action: OutlinedButton(
                    onPressed: () {
                      final notifier = ref.read(
                        resourceFilterProvider.notifier,
                      );
                      notifier.update((f) => f.cleared().copyWith(query: ''));
                    },
                    child: Text(l10n.resourcesClearFilters),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverResourceGrid(resources: visible),
                    const SliverToBoxAdapter(child: Gap.lg),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyLibrary extends ConsumerWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppStateView(
      icon: Icons.collections_bookmark_outlined,
      title: l10n.resourcesEmptyTitle,
      message: l10n.resourcesEmptyMessage,
      action: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => ResourceActions.openForm(context),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.resourcesNew),
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
