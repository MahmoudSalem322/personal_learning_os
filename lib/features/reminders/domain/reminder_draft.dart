import 'package:flutter/foundation.dart' show immutable;

import '../../../core/errors/app_exception.dart';
import 'reminder.dart';

/// The editable parts of a reminder, as the form holds them.
@immutable
class ReminderDraft {
  const ReminderDraft({
    required this.target,
    required this.remindAt,
    this.targetId,
    this.title = '',
    this.repeat = ReminderRepeat.none,
  });

  factory ReminderDraft.fromReminder(Reminder r) => ReminderDraft(
    target: r.target,
    targetId: r.targetId,
    title: r.title,
    remindAt: r.remindAt,
    repeat: r.repeat,
  );

  final ReminderTarget target;
  final String? targetId;
  final String title;
  final DateTime remindAt;
  final ReminderRepeat repeat;

  /// Title trimmed; seconds dropped from the time.
  ReminderDraft normalized() {
    final at = remindAt.toLocal();
    return ReminderDraft(
      target: target,
      targetId: target == ReminderTarget.session ? null : targetId,
      title: title.trim().replaceAll(RegExp(r'\s+'), ' '),
      remindAt: DateTime(at.year, at.month, at.day, at.hour, at.minute),
      repeat: repeat,
    );
  }
}

abstract final class ReminderRules {
  static const int titleMaxLength = 120;
}

/// Why a [ReminderDraft] was rejected.
enum ReminderFieldError {
  /// A learning session needs a label.
  titleRequired,
  titleTooLong,

  /// Task and resource reminders need their item.
  targetRequired,

  /// A one-off reminder must be in the future.
  timeInPast,
}

/// Thrown by `ReminderService` when a draft is invalid.
final class ReminderValidationException extends AppException {
  ReminderValidationException(this.errors)
    : super('Invalid reminder: ${errors.map((e) => e.name).join(', ')}');

  final Set<ReminderFieldError> errors;
}
