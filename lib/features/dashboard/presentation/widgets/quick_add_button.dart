import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../categories/presentation/category_actions.dart';
import '../../../notes/presentation/note_actions.dart';
import '../../../resources/presentation/resource_actions.dart';
import '../../../tasks/presentation/task_actions.dart';

/// "Quick add" menu: new category, resource, note or task in one step.
class QuickAddButton extends ConsumerWidget {
  const QuickAddButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    MenuItemButton item(IconData icon, String label, VoidCallback onPressed) =>
        MenuItemButton(
          leadingIcon: Icon(icon, size: AppSizes.iconMd),
          onPressed: onPressed,
          child: Text(label),
        );

    return MenuAnchor(
      menuChildren: [
        item(
          Icons.collections_bookmark_outlined,
          l10n.quickAddResource,
          () => ResourceActions.openForm(context),
        ),
        item(
          Icons.sticky_note_2_outlined,
          l10n.quickAddNote,
          () => NoteActions.createAndOpen(context, ref),
        ),
        item(
          Icons.check_circle_outline_rounded,
          l10n.quickAddTask,
          () => TaskActions.openForm(context),
        ),
        item(
          Icons.category_outlined,
          l10n.quickAddCategory,
          () => CategoryActions.openForm(context),
        ),
      ],
      builder: (context, controller, _) => FilledButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
        label: Text(l10n.dashboardQuickAdd),
      ),
    );
  }
}
