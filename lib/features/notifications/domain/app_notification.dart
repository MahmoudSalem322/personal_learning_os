import 'package:flutter/foundation.dart' show immutable;

/// Kinds of notification. The UI builds localized text from the kind and
/// the stored details, so switching language updates old notifications too.
enum NotificationType {
  /// A reminder set on a task fired.
  taskReminder,

  /// An open task is due today or tomorrow.
  upcomingTask,

  /// An open task is past its due date.
  overdueTask,

  /// A reminder for a resource or a learning session fired.
  learningReminder,

  /// A message from the app itself (see [SystemNotice]).
  system,
}

/// What a notification opens when tapped.
enum NotificationTarget { none, task, resource }

/// Messages of [NotificationType.system] notifications.
enum SystemNotice { welcome }

/// One entry of the in-app notification inbox.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.key,
    required this.createdAt,
    this.subject = '',
    this.note = '',
    this.target = NotificationTarget.none,
    this.targetId,
    this.dueDate,
    this.notice,
    this.readAt,
    this.dismissedAt,
  });

  /// Parses a stored record. Required fields throw [FormatException];
  /// optional ones fall back to defaults.
  factory AppNotification.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('AppNotification.$key: expected String');
    }

    String optionalString(String key) =>
        json[key] is String ? json[key]! as String : '';

    DateTime? optionalDate(String key) {
      final value = json[key];
      return value is String ? DateTime.tryParse(value) : null;
    }

    final created = DateTime.tryParse(readString(_Keys.createdAt));
    if (created == null) {
      throw const FormatException('AppNotification.createdAt: bad date');
    }
    final rawTargetId = json[_Keys.targetId];
    final rawNotice = json[_Keys.notice];
    final rawDue = optionalDate(_Keys.dueDate);
    return AppNotification(
      id: readString(_Keys.id),
      type: NotificationType.values.firstWhere(
        (t) => t.name == json[_Keys.type],
        orElse: () => NotificationType.system,
      ),
      key: readString(_Keys.key),
      subject: optionalString(_Keys.subject),
      note: optionalString(_Keys.note),
      target: NotificationTarget.values.firstWhere(
        (t) => t.name == json[_Keys.target],
        orElse: () => NotificationTarget.none,
      ),
      targetId: rawTargetId is String && rawTargetId.isNotEmpty
          ? rawTargetId
          : null,
      dueDate: rawDue == null
          ? null
          : DateTime(rawDue.year, rawDue.month, rawDue.day),
      notice: SystemNotice.values.where((n) => n.name == rawNotice).firstOrNull,
      createdAt: created,
      readAt: optionalDate(_Keys.readAt),
      dismissedAt: optionalDate(_Keys.dismissedAt),
    );
  }

  final String id;
  final NotificationType type;

  /// Identifies what the notification is about (e.g. `overdue:<task>:<day>`)
  /// so the same alert is never created twice.
  final String key;

  /// Title of the task/resource (or the session label) when it was created.
  final String subject;

  /// The reminder's note, if any.
  final String note;
  final NotificationTarget target;
  final String? targetId;

  /// Due day of the task, for upcoming/overdue notifications.
  final DateTime? dueDate;

  /// The message of a system notification.
  final SystemNotice? notice;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Removed from the inbox. Kept for a while so it isn't created again.
  final DateTime? dismissedAt;

  bool get isRead => readAt != null;
  bool get isDismissed => dismissedAt != null;

  static const Object _unset = Object();

  AppNotification copyWith({
    Object? readAt = _unset,
    Object? dismissedAt = _unset,
  }) {
    return AppNotification(
      id: id,
      type: type,
      key: key,
      subject: subject,
      note: note,
      target: target,
      targetId: targetId,
      dueDate: dueDate,
      notice: notice,
      createdAt: createdAt,
      readAt: identical(readAt, _unset) ? this.readAt : readAt as DateTime?,
      dismissedAt: identical(dismissedAt, _unset)
          ? this.dismissedAt
          : dismissedAt as DateTime?,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.type: type.name,
    _Keys.key: key,
    _Keys.subject: subject,
    _Keys.note: note,
    _Keys.target: target.name,
    _Keys.targetId: targetId,
    _Keys.dueDate: dueDate == null ? null : formatDay(dueDate!),
    _Keys.notice: notice?.name,
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.readAt: readAt?.toUtc().toIso8601String(),
    _Keys.dismissedAt: dismissedAt?.toUtc().toIso8601String(),
  };

  /// `yyyy-MM-dd` of a calendar day.
  static String formatDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is AppNotification &&
      other.id == id &&
      other.key == key &&
      other.type == type &&
      other.subject == subject &&
      other.note == note &&
      other.target == target &&
      other.targetId == targetId &&
      other.dueDate == dueDate &&
      other.notice == notice &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      _sameMoment(other.readAt, readAt) &&
      _sameMoment(other.dismissedAt, dismissedAt);

  @override
  int get hashCode => Object.hash(
    id,
    key,
    type,
    subject,
    note,
    target,
    targetId,
    dueDate,
    notice,
    createdAt.millisecondsSinceEpoch,
    readAt?.millisecondsSinceEpoch,
    dismissedAt?.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'AppNotification($id, ${type.name}, $key)';

  static bool _sameMoment(DateTime? a, DateTime? b) =>
      a == null ? b == null : b != null && a.isAtSameMomentAs(b);
}

abstract final class _Keys {
  static const id = 'id';
  static const type = 'type';
  static const key = 'key';
  static const subject = 'subject';
  static const note = 'note';
  static const target = 'target';
  static const targetId = 'targetId';
  static const dueDate = 'dueDate';
  static const notice = 'notice';
  static const createdAt = 'createdAt';
  static const readAt = 'readAt';
  static const dismissedAt = 'dismissedAt';
}
