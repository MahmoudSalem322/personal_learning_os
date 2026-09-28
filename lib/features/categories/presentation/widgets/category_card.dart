import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../resources/domain/learning_progress.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../domain/category.dart';
import 'category_avatar.dart';
import 'category_menu_button.dart';

/// Grid card for a category: identity, description, resource count and
/// progress. Clicking it opens the category.
class CategoryCard extends ConsumerWidget {
  const CategoryCard({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;
    final hasDescription = category.description.isNotEmpty;
    // Rebuilds only when this category's numbers change.
    final progress = ref.watch(
      categoryProgressProvider.select(
        (all) => all[category.id] ?? LearningProgress.empty,
      ),
    );

    return AppCard(
      onTap: () => context.go(AppRoutes.category(category.id)),
      semanticLabel: category.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryAvatar(
                icon: category.icon,
                primaryColor: category.primaryColor,
                secondaryColor: category.secondaryColor,
              ),
              const Spacer(),
              CategoryMenuButton(category: category),
            ],
          ),
          Gap.sm,
          Text(
            category.name,
            style: text.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap.xxs,
          Expanded(
            child: Text(
              hasDescription
                  ? category.description
                  : l10n.categoryNoDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(
                color: colors.mutedText,
                fontStyle: hasDescription ? null : FontStyle.italic,
              ),
            ),
          ),
          Gap.xs,
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.categoryResourcesCount(progress.resourceCount),
                  style: text.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (progress.percent != null)
                Text(
                  l10n.progressPercent(progress.percent!),
                  style: text.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
            ],
          ),
          Gap.xs,
          AppProgressBar(percent: progress.percent ?? 0, height: 4),
        ],
      ),
    );
  }
}
