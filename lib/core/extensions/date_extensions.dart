import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

extension DateFormattingX on BuildContext {
  /// Medium date in the current locale, e.g. "Sep 28, 2026" / "٢٨ سبتمبر ٢٠٢٦".
  String formatDate(DateTime date) =>
      DateFormat.yMMMd(Localizations.localeOf(this).toLanguageTag())
          .format(date.toLocal());
}

extension FullDateFormattingX on BuildContext {
  /// Long date with weekday, e.g. "Wednesday, September 30, 2026".
  String formatFullDate(DateTime date) =>
      DateFormat.yMMMMEEEEd(Localizations.localeOf(this).toLanguageTag())
          .format(date.toLocal());
}

extension RelativeDateFormattingX on BuildContext {
  /// Time of day in the current locale, e.g. "8:30 PM" / "٨:٣٠ م".
  String formatTime(DateTime moment) =>
      DateFormat.jm(Localizations.localeOf(this).toLanguageTag())
          .format(moment.toLocal());

  /// "Just now", "5 min ago", "3 h ago", "Yesterday" or the date.
  String formatRelative(DateTime moment, {DateTime? now}) {
    final l10n = AppLocalizations.of(this);
    final current = now ?? DateTime.now();
    final local = moment.toLocal();
    final elapsed = current.difference(local);
    if (elapsed.inMinutes < 1) return l10n.timeJustNow;
    if (elapsed.inMinutes < 60) return l10n.timeMinutesAgo(elapsed.inMinutes);
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return l10n.timeHoursAgo(elapsed.inHours);
    if (today.difference(day).inDays == 1) return l10n.timeYesterday;
    return formatDate(local);
  }

  /// "Today at 8:30 PM", "Tomorrow at 9:00 AM" or "Oct 2, 2026 at 9:00 AM".
  String formatWhen(DateTime moment, {DateTime? now}) {
    final l10n = AppLocalizations.of(this);
    final current = now ?? DateTime.now();
    final local = moment.toLocal();
    final today = DateTime(current.year, current.month, current.day);
    final days = DateTime(
      local.year,
      local.month,
      local.day,
    ).difference(today).inDays;
    final time = formatTime(local);
    return switch (days) {
      0 => l10n.timeTodayAt(time),
      1 => l10n.timeTomorrowAt(time),
      -1 => l10n.timeYesterdayAt(time),
      _ => l10n.timeDateAt(formatDate(local), time),
    };
  }
}
