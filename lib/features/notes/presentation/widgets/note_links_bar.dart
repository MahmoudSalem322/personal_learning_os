import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../resources/domain/resource.dart';
import '../../../resources/presentation/widgets/resource_chip.dart';
import '../../../resources/presentation/widgets/resource_picker_dialog.dart';

/// Category and resource pickers shown under the note title.
class NoteLinksBar extends ConsumerWidget {
  const NoteLinksBar({
    required this.categoryId,
    required this.resourceId,
    required this.onCategoryChanged,
    required this.onResourceChanged,
    super.key,
  });

  final String? categoryId;
  final String? resourceId;
  final ValueChanged<String?> onCategoryChanged;

  /// Receives the new resource (or `null` to unlink).
  final ValueChanged<Resource?> onResourceChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(
                Icons.block_rounded,
                size: AppSizes.iconMd,
              ),
              onPressed: () => onCategoryChanged(null),
              child: Text(l10n.resourceFormNoCategory),
            ),
            for (final c in categories)
              MenuItemButton(
                leadingIcon: CategoryAvatar(
                  icon: c.icon,
                  primaryColor: c.primaryColor,
                  secondaryColor: c.secondaryColor,
                  size: 22,
                ),
                onPressed: () => onCategoryChanged(c.id),
                child: Text(c.name),
              ),
          ],
          builder: (context, menu, _) => _LinkButton(
            icon: Icons.category_outlined,
            tooltip: l10n.resourceFormCategory,
            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            child:
                categoryId == null || !categories.any((c) => c.id == categoryId)
                ? Text(l10n.resourceFormCategory)
                : CategoryChip(categoryId: categoryId),
          ),
        ),
        _LinkButton(
          icon: Icons.collections_bookmark_outlined,
          tooltip: l10n.noteResource,
          onPressed: () async {
            final pick = await showResourcePicker(
              context,
              selectedId: resourceId,
            );
            if (pick == null) return;
            onResourceChanged(pick.cleared ? null : pick.resource);
          },
          child: resourceId == null
              ? Text(l10n.noteResource)
              : ResourceChip(resourceId: resourceId),
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          foregroundColor: colors.mutedText,
          side: BorderSide(color: colors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSm),
              Gap.xs,
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
