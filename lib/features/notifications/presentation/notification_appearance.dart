import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_notification.dart';

/// Icon, colors and localized text of a notification.
extension NotificationAppearance on AppNotification {
  IconData get icon => switch (type) {
    NotificationType.taskReminder => Icons.alarm_rounded,
    NotificationType.upcomingTask => Icons.event_rounded,
    NotificationType.overdueTask => Icons.event_busy_rounded,
    NotificationType.learningReminder => Icons.school_outlined,
    NotificationType.system => Icons.auto_awesome_outlined,
  };

  (Color foreground, Color background) colorsIn(AppColors colors) =>
      switch (type) {
        NotificationType.taskReminder => (colors.primary, colors.primarySoft),
        NotificationType.upcomingTask => (colors.info, colors.infoSoft),
        NotificationType.overdueTask => (colors.error, colors.errorSoft),
        NotificationType.learningReminder => (
          colors.secondary,
          colors.secondarySoft,
        ),
        NotificationType.system => (colors.success, colors.successSoft),
      };

  String title(BuildContext context) => titleIn(context.l10n);

  /// The detail line; due dates are worded relative to [now].
  String body(BuildContext context, {DateTime? now}) => bodyIn(
    context.l10n,
    Localizations.localeOf(context).toLanguageTag(),
    now: now,
  );

  /// [title] without a widget context (e.g. for browser notifications).
  String titleIn(AppLocalizations l10n) => switch (type) {
    NotificationType.taskReminder => l10n.notificationTaskReminder,
    NotificationType.upcomingTask => l10n.notificationUpcomingTask,
    NotificationType.overdueTask => l10n.notificationOverdueTask,
    NotificationType.learningReminder => l10n.notificationLearningReminder,
    NotificationType.system => switch (notice) {
      SystemNotice.welcome || null => l10n.notificationWelcomeTitle,
    },
  };

  /// [body] without a widget context; [locale] formats dates.
  String bodyIn(AppLocalizations l10n, String locale, {DateTime? now}) {
    String withNote(String text) => note.isEmpty ? text : '$text · $note';
    String date(DateTime day) => DateFormat.yMMMd(locale).format(day);
    switch (type) {
      case NotificationType.taskReminder:
      case NotificationType.learningReminder:
        return withNote(subject);
      case NotificationType.upcomingTask:
        final due = dueDate;
        if (due == null) return subject;
        final current = now ?? DateTime.now();
        final today = DateTime(current.year, current.month, current.day);
        return switch (due.difference(today).inDays) {
          0 => l10n.notificationDueToday(subject),
          1 => l10n.notificationDueTomorrow(subject),
          _ => l10n.notificationDueOn(subject, date(due)),
        };
      case NotificationType.overdueTask:
        final due = dueDate;
        return due == null
            ? subject
            : l10n.notificationWasDue(subject, date(due));
      case NotificationType.system:
        return switch (notice) {
          SystemNotice.welcome || null => l10n.notificationWelcomeMessage,
        };
    }
  }
}
