import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../categories_providers.dart';
import 'category_avatar.dart';

/// Small "icon + name" label for the category of an item. Renders nothing
/// when the category doesn't exist. Links to the category when [linked].
class CategoryChip extends ConsumerWidget {
  const CategoryChip({
    required this.categoryId,
    super.key,
    this.linked = false,
  });

  final String? categoryId;
  final bool linked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = categoryId;
    if (id == null) return const SizedBox.shrink();
    final category = ref.watch(categoryMapProvider.select((m) => m[id]));
    if (category == null) return const SizedBox.shrink();

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CategoryAvatar(
          icon: category.icon,
          primaryColor: category.primaryColor,
          secondaryColor: category.secondaryColor,
          size: 20,
        ),
        Gap.xs,
        Flexible(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelMedium?.copyWith(
              color: linked ? context.colors.text : context.colors.mutedText,
            ),
          ),
        ),
      ],
    );

    if (!linked) return label;
    return InkWell(
      onTap: () => context.go(AppRoutes.category(category.id)),
      borderRadius: AppRadius.chip,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: 2,
        ),
        child: label,
      ),
    );
  }
}
