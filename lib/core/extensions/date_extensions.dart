import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

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
