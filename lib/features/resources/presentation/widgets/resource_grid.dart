import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../domain/resource.dart';
import 'resource_card.dart';

/// Grid geometry shared by resource lists and their skeletons.
abstract final class ResourceGridLayout {
  static const SliverGridDelegate delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 214,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      );
}

/// Lazily built grid of resource cards, for use inside a
/// `CustomScrollView`. Only visible cards are built, so large libraries
/// scroll smoothly.
class SliverResourceGrid extends StatelessWidget {
  const SliverResourceGrid({
    required this.resources,
    super.key,
    this.showCategory = true,
  });

  final List<Resource> resources;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: ResourceGridLayout.delegate,
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ResourceCard(
          key: ValueKey(resource.id),
          resource: resource,
          showCategory: showCategory,
        );
      },
    );
  }
}

/// Loading placeholder shaped like a grid of resource cards.
class ResourceGridSkeleton extends StatelessWidget {
  const ResourceGridSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: ResourceGridLayout.delegate,
      itemCount: count,
      itemBuilder: (_, _) => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeleton(
                  width: 36,
                  height: 36,
                  borderRadius: AppRadius.button,
                ),
                Gap.sm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 160, height: 16),
                    Gap.xxs,
                    AppSkeleton(width: 90, height: 10),
                  ],
                ),
              ],
            ),
            Gap.md,
            AppSkeleton(height: 12),
            Gap.xs,
            AppSkeleton(width: 200, height: 12),
            Spacer(),
            AppSkeleton(height: 6),
          ],
        ),
      ),
    );
  }
}
