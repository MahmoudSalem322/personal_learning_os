import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/category.dart';
import '../category_actions.dart';

/// "More" menu with Edit and Delete for a category.
class CategoryMenuButton extends ConsumerWidget {
  const CategoryMenuButton({required this.category, super.key, this.onDeleted});

  final Category category;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
          onPressed: () =>
              CategoryActions.openForm(context, category: category),
          child: Text(l10n.actionEdit),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: colors.error,
          ),
          onPressed: () => CategoryActions.delete(
            context,
            ref,
            category,
            onDeleted: onDeleted,
          ),
          child: Text(l10n.actionDelete, style: TextStyle(color: colors.error)),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.actionMore,
        icon: const Icon(Icons.more_horiz_rounded, size: AppSizes.iconMd),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
