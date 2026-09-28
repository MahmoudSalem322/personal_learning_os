import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/resource.dart';
import '../resource_actions.dart';

/// "More" menu with Open, Edit and Delete for a resource.
class ResourceMenuButton extends ConsumerWidget {
  const ResourceMenuButton({required this.resource, super.key, this.onDeleted});

  final Resource resource;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    return MenuAnchor(
      menuChildren: [
        if (resource.hasUrl)
          MenuItemButton(
            leadingIcon: const Icon(
              Icons.open_in_new_rounded,
              size: AppSizes.iconMd,
            ),
            onPressed: () => ResourceActions.open(context, ref, resource),
            child: Text(l10n.resourceOpenLink),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
          onPressed: () =>
              ResourceActions.openForm(context, resource: resource),
          child: Text(l10n.actionEdit),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: colors.error,
          ),
          onPressed: () => ResourceActions.delete(
            context,
            ref,
            resource,
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
