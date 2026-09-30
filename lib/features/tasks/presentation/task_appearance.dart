import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/task.dart';
import '../domain/task_filter.dart';

/// Icons and labels of each task priority.
extension TaskPriorityAppearance on TaskPriority {
  IconData get icon => switch (this) {
    TaskPriority.low => Icons.keyboard_double_arrow_down_rounded,
    TaskPriority.medium => Icons.drag_handle_rounded,
    TaskPriority.high => Icons.keyboard_double_arrow_up_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    TaskPriority.low => l10n.taskPriorityLow,
    TaskPriority.medium => l10n.taskPriorityMedium,
    TaskPriority.high => l10n.taskPriorityHigh,
  };
}

/// Icons and labels of each task status.
extension TaskStatusAppearance on TaskStatus {
  IconData get icon => switch (this) {
    TaskStatus.todo => Icons.radio_button_unchecked_rounded,
    TaskStatus.inProgress => Icons.timelapse_rounded,
    TaskStatus.completed => Icons.check_circle_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    TaskStatus.todo => l10n.taskStatusTodo,
    TaskStatus.inProgress => l10n.taskStatusInProgress,
    TaskStatus.completed => l10n.taskStatusCompleted,
  };
}

/// Labels of the tasks page views (tabs).
extension TaskViewAppearance on TaskView {
  String label(AppLocalizations l10n) => switch (this) {
    TaskView.all => l10n.taskViewAll,
    TaskView.today => l10n.taskViewToday,
    TaskView.upcoming => l10n.taskViewUpcoming,
    TaskView.overdue => l10n.taskViewOverdue,
    TaskView.completed => l10n.taskViewCompleted,
  };
}

/// A small pill for a priority or status value.
class TaskBadge extends StatelessWidget {
  const TaskBadge({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: foreground),
          Gap.xxs,
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Priority badge using the theme's status colors.
class TaskPriorityBadge extends StatelessWidget {
  const TaskPriorityBadge({required this.priority, super.key});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (foreground, background) = switch (priority) {
      TaskPriority.low => (colors.mutedText, colors.surfaceMuted),
      TaskPriority.medium => (colors.info, colors.infoSoft),
      TaskPriority.high => (colors.error, colors.errorSoft),
    };
    final l10n = AppLocalizations.of(context);
    return TaskBadge(
      label: priority.label(l10n),
      icon: priority.icon,
      foreground: foreground,
      background: background,
    );
  }
}

/// Status badge using the theme's status colors.
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({required this.status, super.key});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (foreground, background) = switch (status) {
      TaskStatus.todo => (colors.mutedText, colors.surfaceMuted),
      TaskStatus.inProgress => (colors.info, colors.infoSoft),
      TaskStatus.completed => (colors.success, colors.successSoft),
    };
    final l10n = AppLocalizations.of(context);
    return TaskBadge(
      label: status.label(l10n),
      icon: status.icon,
      foreground: foreground,
      background: background,
    );
  }
}
