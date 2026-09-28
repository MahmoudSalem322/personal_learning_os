import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/category.dart';
import 'category_avatar.dart';
import 'category_menu_button.dart';

/// Grid card for a category. Clicking it opens the category.
class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final hasDescription = category.description.isNotEmpty;

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
                  : context.l10n.categoryNoDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(
                color: colors.mutedText,
                fontStyle: hasDescription ? null : FontStyle.italic,
              ),
            ),
          ),
          Text(
            context.l10n.dateUpdatedOn(context.formatDate(category.updatedAt)),
            style: text.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
