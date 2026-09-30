import 'package:flutter/foundation.dart' show immutable;

/// What a reminder is about.
enum ReminderTarget {
  /// A task (`targetId` is the task id).
  task,

  /// A resource to study (`targetId` is the resource id).
  resource,

  /// A learning session with its own label; no linked item.
  session,
}

/// How often a reminder comes back after it fires.
enum ReminderRepeat {
  none,
  daily,
  weekly;

  /// The period between occurrences, or `null` for one-off reminders.
  Duration? get period => switch (this) {
    ReminderRepeat.none => null,
    ReminderRepeat.daily => const Duration(days: 1),
    ReminderRepeat.weekly => const Duration(days: 7),
  };
}

/// A moment at which the app notifies the user about a task, a resource or
/// a learning session.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.target,
    required this.remindAt,
    required this.createdAt,
    required this.updatedAt,
    this.targetId,
    this.title = '',
    this.repeat = ReminderRepeat.none,
    this.isEnabled = true,
    this.lastFiredAt,
  });

  /// Parses a stored record. Required fields throw [FormatException];
  /// optional ones fall back to defaults.
  factory Reminder.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('Reminder.$key: expected String, got $value');
    }

    DateTime readDate(String key) {
      final parsed = DateTime.tryParse(readString(key));
      if (parsed == null) throw FormatException('Reminder.$key: bad date');
      return parsed;
    }

    T byName<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.firstWhere((v) => v.name == raw, orElse: () => fallback);

    final rawTargetId = json[_Keys.targetId];
    final rawFired = json[_Keys.lastFiredAt];
    return Reminder(
      id: readString(_Keys.id),
      target: byName(
        ReminderTarget.values,
        json[_Keys.target],
        ReminderTarget.session,
      ),
      targetId: rawTargetId is String && rawTargetId.isNotEmpty
          ? rawTargetId
          : null,
      title: json[_Keys.title] is String ? json[_Keys.title]! as String : '',
      remindAt: readDate(_Keys.remindAt),
      repeat: byName(
        ReminderRepeat.values,
        json[_Keys.repeat],
        ReminderRepeat.none,
      ),
      isEnabled: json[_Keys.isEnabled] != false,
      lastFiredAt: rawFired is String ? DateTime.tryParse(rawFired) : null,
      createdAt: readDate(_Keys.createdAt),
      updatedAt: readDate(_Keys.updatedAt),
    );
  }

  final String id;
  final ReminderTarget target;

  /// Id of the task or resource; `null` for [ReminderTarget.session].
  final String? targetId;

  /// The session label, or an optional note for task/resource reminders.
  final String title;

  /// Next time the reminder fires (a moment, not a calendar day).
  final DateTime remindAt;
  final ReminderRepeat repeat;

  /// Paused reminders never fire.
  final bool isEnabled;

  /// When it last fired; a one-off reminder is finished once set.
  final DateTime? lastFiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRepeating => repeat != ReminderRepeat.none;

  /// A one-off reminder that already fired.
  bool get isFinished => !isRepeating && lastFiredAt != null;

  /// Whether it should fire at [now].
  bool isDue(DateTime now) =>
      isEnabled && !isFinished && !remindAt.isAfter(now);

  /// First occurrence strictly after [now], keeping the time of day. Missed
  /// occurrences are skipped, so a reminder fires once when the app reopens.
  DateTime nextAfter(DateTime now) {
    final period = repeat.period;
    if (period == null) return remindAt;
    var next = remindAt;
    while (!next.isAfter(now)) {
      final local = next.toLocal();
      // Calendar arithmetic keeps the wall-clock time across DST changes.
      next = DateTime(
        local.year,
        local.month,
        local.day + period.inDays,
        local.hour,
        local.minute,
      );
    }
    return next;
  }

  static const Object _unset = Object();

  Reminder copyWith({
    ReminderTarget? target,
    Object? targetId = _unset,
    String? title,
    DateTime? remindAt,
    ReminderRepeat? repeat,
    bool? isEnabled,
    Object? lastFiredAt = _unset,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id,
      target: target ?? this.target,
      targetId: identical(targetId, _unset)
          ? this.targetId
          : targetId as String?,
      title: title ?? this.title,
      remindAt: remindAt ?? this.remindAt,
      repeat: repeat ?? this.repeat,
      isEnabled: isEnabled ?? this.isEnabled,
      lastFiredAt: identical(lastFiredAt, _unset)
          ? this.lastFiredAt
          : lastFiredAt as DateTime?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.target: target.name,
    _Keys.targetId: targetId,
    _Keys.title: title,
    _Keys.remindAt: remindAt.toUtc().toIso8601String(),
    _Keys.repeat: repeat.name,
    _Keys.isEnabled: isEnabled,
    _Keys.lastFiredAt: lastFiredAt?.toUtc().toIso8601String(),
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.target == target &&
      other.targetId == targetId &&
      other.title == title &&
      other.remindAt.isAtSameMomentAs(remindAt) &&
      other.repeat == repeat &&
      other.isEnabled == isEnabled &&
      _sameMoment(other.lastFiredAt, lastFiredAt) &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    target,
    targetId,
    title,
    remindAt.millisecondsSinceEpoch,
    repeat,
    isEnabled,
    lastFiredAt?.millisecondsSinceEpoch,
    createdAt.millisecondsSinceEpoch,
    updatedAt.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Reminder($id, ${target.name}, $remindAt)';

  static bool _sameMoment(DateTime? a, DateTime? b) =>
      a == null ? b == null : b != null && a.isAtSameMomentAs(b);
}

abstract final class _Keys {
  static const id = 'id';
  static const target = 'target';
  static const targetId = 'targetId';
  static const title = 'title';
  static const remindAt = 'remindAt';
  static const repeat = 'repeat';
  static const isEnabled = 'isEnabled';
  static const lastFiredAt = 'lastFiredAt';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
