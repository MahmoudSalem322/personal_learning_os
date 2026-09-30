import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../domain/reminder.dart';
import '../reminder_actions.dart';
import '../reminder_appearance.dart';
import '../reminders_providers.dart';

/// Title of the task/resource a reminder points to; `null` when it was
/// deleted, the session label for sessions.
String? reminderSubject(WidgetRef ref, Reminder r) => switch (r.target) {
  ReminderTarget.session => r.title,
  ReminderTarget.task =>
    (ref.watch(tasksProvider).value ?? const [])
        .where((t) => t.id == r.targetId)
        .firstOrNull
        ?.title,
  ReminderTarget.resource =>
    (ref.watch(resourcesProvider).value ?? const [])
        .where((x) => x.id == r.targetId)
        .firstOrNull
        ?.title,
};

/// One reminder: what, when, how often, with pause switch and menu.
///
/// [showSubject] is false inside a task/resource page, where the item is
/// obvious; the time then becomes the title.
class ReminderTile extends ConsumerWidget {
  const ReminderTile({
    required this.reminder,
    super.key,
    this.showSubject = true,
  });

  final Reminder reminder;
  final bool showSubject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final r = reminder;
    final subject = reminderSubject(ref, r);
    final missing = subject == null;
    final active = r.isEnabled && !r.isFinished;

    final when = r.isFinished
        ? l10n.reminderDone(context.formatRelative(r.lastFiredAt!))
        : context.formatWhen(r.remindAt);
    final details = [
      if (showSubject) when,
      if (r.isRepeating) r.repeat.label(l10n),
      if (!r.isEnabled && !r.isFinished) l10n.reminderPaused,
      if (r.target != ReminderTarget.session && r.title.isNotEmpty) r.title,
    ].join(' · ');

    final title = !showSubject
        ? when
        : missing
        ? l10n.reminderItemDeleted
        : subject;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.chip,
        onTap: () => ReminderActions.openForm(
          context,
          reminder: r,
          targetTitle: subject,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Opacity(
                opacity: active ? 1 : 0.5,
                child: AppIconTile(
                  icon: showSubject ? r.target.icon : Icons.alarm_rounded,
                ),
              ),
              Gap.sm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyStrong.copyWith(
                        color: active && !missing ? null : colors.mutedText,
                        fontStyle: missing && showSubject
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.caption.copyWith(color: colors.mutedText),
                      ),
                  ],
                ),
              ),
              if (!r.isFinished)
                Tooltip(
                  message: r.isEnabled
                      ? l10n.reminderPause
                      : l10n.reminderResume,
                  child: Switch(
                    value: r.isEnabled,
                    onChanged: (value) => ReminderActions.setEnabled(
                      context,
                      ref,
                      r,
                      enabled: value,
                    ),
                  ),
                ),
              IconButton(
                tooltip: l10n.actionDelete,
                onPressed: () => ReminderActions.delete(context, ref, r),
                icon: Icon(
                  Icons.close_rounded,
                  size: AppSizes.iconSm,
                  color: colors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reminders of one task or resource, for its detail page.
class ItemReminders extends ConsumerWidget {
  const ItemReminders({
    required this.target,
    required this.targetId,
    super.key,
  });

  final ReminderTarget target;
  final String targetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersForProvider((target, targetId)));
    if (reminders.isEmpty) {
      return Text(
        context.l10n.remindersNoneForItem,
        style: context.textStyles.caption,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in reminders)
          ReminderTile(key: ValueKey(r.id), reminder: r, showSubject: false),
      ],
    );
  }
}
