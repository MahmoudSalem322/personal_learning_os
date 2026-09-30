import 'package:flutter/foundation.dart' show immutable;

/// Which notifications the app creates. Stored with the app settings.
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    this.enabled = true,
    this.reminders = true,
    this.upcomingTasks = true,
    this.overdueTasks = true,
  });

  /// Missing or invalid values fall back to the defaults (all on).
  factory NotificationPreferences.fromJson(Object? json) {
    if (json is! Map) return defaults;
    bool read(String key) => json[key] is bool ? json[key] as bool : true;
    return NotificationPreferences(
      enabled: read(_Keys.enabled),
      reminders: read(_Keys.reminders),
      upcomingTasks: read(_Keys.upcomingTasks),
      overdueTasks: read(_Keys.overdueTasks),
    );
  }

  static const NotificationPreferences defaults = NotificationPreferences();

  /// Master switch: when off, nothing new is created.
  final bool enabled;

  /// Task, resource and learning-session reminders.
  final bool reminders;

  /// Open tasks due today or tomorrow.
  final bool upcomingTasks;

  /// Open tasks past their due date.
  final bool overdueTasks;

  bool get allowsReminders => enabled && reminders;
  bool get allowsUpcoming => enabled && upcomingTasks;
  bool get allowsOverdue => enabled && overdueTasks;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? reminders,
    bool? upcomingTasks,
    bool? overdueTasks,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      reminders: reminders ?? this.reminders,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.enabled: enabled,
    _Keys.reminders: reminders,
    _Keys.upcomingTasks: upcomingTasks,
    _Keys.overdueTasks: overdueTasks,
  };

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences &&
      other.enabled == enabled &&
      other.reminders == reminders &&
      other.upcomingTasks == upcomingTasks &&
      other.overdueTasks == overdueTasks;

  @override
  int get hashCode =>
      Object.hash(enabled, reminders, upcomingTasks, overdueTasks);
}

abstract final class _Keys {
  static const enabled = 'enabled';
  static const reminders = 'reminders';
  static const upcomingTasks = 'upcomingTasks';
  static const overdueTasks = 'overdueTasks';
}
