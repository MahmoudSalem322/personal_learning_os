import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/reminder.dart';

extension ReminderRepeatAppearance on ReminderRepeat {
  String label(AppLocalizations l10n) => switch (this) {
    ReminderRepeat.none => l10n.reminderRepeatNone,
    ReminderRepeat.daily => l10n.reminderRepeatDaily,
    ReminderRepeat.weekly => l10n.reminderRepeatWeekly,
  };
}

extension ReminderTargetAppearance on ReminderTarget {
  IconData get icon => switch (this) {
    ReminderTarget.task => Icons.check_circle_outline_rounded,
    ReminderTarget.resource => Icons.collections_bookmark_outlined,
    ReminderTarget.session => Icons.school_outlined,
  };
}
