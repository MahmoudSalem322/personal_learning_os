import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/task.dart';
import '../task_actions.dart';

/// "More" menu with Edit, status changes and Delete for a task.
class TaskMenuButton extends ConsumerWidget {
  const TaskMenuButton({required this.task, super.key, this.onDeleted});

  final Task task;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
          onPressed: () => TaskActions.openForm(context, task: task),
          child: Text(l10n.actionEdit),
        ),
        if (!task.isCompleted) ...[
          MenuItemButton(
            leadingIcon: const Icon(
              Icons.timelapse_rounded,
              size: AppSizes.iconMd,
            ),
            onPressed: () => TaskActions.setStatus(
              context,
              ref,
              task,
              TaskStatus.inProgress,
            ),
            child: Text(l10n.taskStatusInProgress),
          ),
          MenuItemButton(
            leadingIcon: const Icon(
              Icons.check_circle_outline_rounded,
              size: AppSizes.iconMd,
            ),
            onPressed: () =>
                TaskActions.setStatus(context, ref, task, TaskStatus.completed),
            child: Text(l10n.taskComplete),
          ),
        ] else
          MenuItemButton(
            leadingIcon: const Icon(
              Icons.radio_button_unchecked_rounded,
              size: AppSizes.iconMd,
            ),
            onPressed: () =>
                TaskActions.setStatus(context, ref, task, TaskStatus.todo),
            child: Text(l10n.taskReopen),
          ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: colors.error,
          ),
          onPressed: () =>
              TaskActions.delete(context, ref, task, onDeleted: onDeleted),
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
