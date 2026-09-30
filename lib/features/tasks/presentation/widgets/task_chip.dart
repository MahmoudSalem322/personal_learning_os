import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';

/// Small "status icon + title" label for a linked task. Renders nothing
/// when the task doesn't exist. Links to it when [linked].
class TaskChip extends ConsumerWidget {
  const TaskChip({required this.taskId, super.key, this.linked = false});

  final String? taskId;
  final bool linked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = taskId;
    if (id == null) return const SizedBox.shrink();
    final task = ref.watch(
      tasksProvider.select(
        (all) => all.value?.where((t) => t.id == id).firstOrNull,
      ),
    );
    if (task == null) return const SizedBox.shrink();
    final colors = context.colors;

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(task.status.icon, size: AppSizes.iconSm, color: colors.mutedText),
        Gap.xxs,
        Flexible(
          child: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelMedium?.copyWith(
              color: linked ? colors.text : colors.mutedText,
            ),
          ),
        ),
      ],
    );
    if (!linked) return label;
    return InkWell(
      onTap: () => context.go(AppRoutes.task(task.id)),
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
