import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';

/// Loading placeholder shaped like a `CategoryCard`.
class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: 40, height: 40, borderRadius: AppRadius.button),
          Gap.md,
          AppSkeleton(width: 140, height: 18),
          Gap.xs,
          AppSkeleton(height: 12),
          Gap.xs,
          AppSkeleton(width: 180, height: 12),
          Spacer(),
          AppSkeleton(width: 110, height: 10),
        ],
      ),
    );
  }
}

/// Spacing shared by the categories grid and its skeleton.
abstract final class CategoryGridLayout {
  static const SliverGridDelegate delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: 184,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      );
}
