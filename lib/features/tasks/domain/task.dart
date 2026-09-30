import 'package:flutter/foundation.dart' show immutable, listEquals;

/// How urgent a task is.
enum TaskPriority { low, medium, high }

/// Where a task is in its life cycle.
enum TaskStatus { todo, inProgress, completed }

/// A single step of the learning plan. It can stand alone or be linked to
/// a category and/or a resource.
@immutable
class Task {
  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.categoryId,
    this.resourceId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.completedAt,
    this.isFavorite = false,
    List<String> tags = const [],
  }) : tags = List.unmodifiable(tags);

  /// Parses a stored record. Required fields (id, title, dates) throw
  /// [FormatException]; optional ones fall back to defaults so records from
  /// older or newer versions still load.
  factory Task.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('Task.$key: expected String, got $value');
    }

    DateTime readDate(String key) {
      final parsed = DateTime.tryParse(readString(key));
      if (parsed == null) throw FormatException('Task.$key: bad date');
      return parsed;
    }

    String? optionalId(String key) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    DateTime? optionalDate(String key) {
      final value = json[key];
      return value is String ? DateTime.tryParse(value) : null;
    }

    final rawTags = json[_Keys.tags];
    final rawPriority = json[_Keys.priority];
    final rawStatus = json[_Keys.status];

    return Task(
      id: readString(_Keys.id),
      title: readString(_Keys.title),
      description: json[_Keys.description] is String
          ? json[_Keys.description]! as String
          : '',
      categoryId: optionalId(_Keys.categoryId),
      resourceId: optionalId(_Keys.resourceId),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == rawPriority,
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == rawStatus,
        orElse: () => TaskStatus.todo,
      ),
      dueDate: _parseDay(json[_Keys.dueDate]),
      completedAt: optionalDate(_Keys.completedAt),
      isFavorite: json[_Keys.isFavorite] == true,
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      createdAt: readDate(_Keys.createdAt),
      updatedAt: readDate(_Keys.updatedAt),
    );
  }

  final String id;
  final String title;
  final String description;

  /// `null` when the task isn't in any category.
  final String? categoryId;

  /// `null` when the task isn't linked to a resource.
  final String? resourceId;
  final TaskPriority priority;
  final TaskStatus status;

  /// Day the task is due, at local midnight. Date-only: no time of day.
  final DateTime? dueDate;

  /// Set when the task entered [TaskStatus.completed]; cleared otherwise.
  final DateTime? completedAt;

  final bool isFavorite;

  /// Normalized tags without the leading `#`.
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;

  /// Whether the task is past its due date and still open.
  bool isOverdue(DateTime now) {
    final due = dueDate;
    if (due == null || isCompleted) return false;
    return now.isAfter(DateTime(due.year, due.month, due.day, 23, 59, 59, 999));
  }

  /// Whether the task is due on the day of [date] (local) and still open.
  /// A task due today is never overdue: "overdue" starts tomorrow.
  bool isDueOn(DateTime date) {
    final due = dueDate;
    if (due == null || isCompleted) return false;
    return due.year == date.year &&
        due.month == date.month &&
        due.day == date.day;
  }

  static const Object _unset = Object();

  /// Pass `null` for [categoryId], [resourceId], [dueDate] or [completedAt]
  /// to remove them; omit them to keep the current value.
  Task copyWith({
    String? title,
    String? description,
    Object? categoryId = _unset,
    Object? resourceId = _unset,
    TaskPriority? priority,
    TaskStatus? status,
    Object? dueDate = _unset,
    Object? completedAt = _unset,
    bool? isFavorite,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      resourceId: identical(resourceId, _unset)
          ? this.resourceId
          : resourceId as String?,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.title: title,
    _Keys.description: description,
    _Keys.categoryId: categoryId,
    _Keys.resourceId: resourceId,
    _Keys.priority: priority.name,
    _Keys.status: status.name,
    _Keys.dueDate: dueDate == null ? null : _formatDay(dueDate!),
    _Keys.completedAt: completedAt?.toUtc().toIso8601String(),
    _Keys.isFavorite: isFavorite,
    _Keys.tags: tags,
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.categoryId == categoryId &&
      other.resourceId == resourceId &&
      other.priority == priority &&
      other.status == status &&
      _sameMoment(other.dueDate, dueDate) &&
      _sameMoment(other.completedAt, completedAt) &&
      other.isFavorite == isFavorite &&
      listEquals(other.tags, tags) &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    categoryId,
    resourceId,
    priority,
    status,
    dueDate?.millisecondsSinceEpoch,
    completedAt?.millisecondsSinceEpoch,
    isFavorite,
    Object.hashAll(tags),
    createdAt.millisecondsSinceEpoch,
    updatedAt.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Task($id, $title)';

  /// Due dates are calendar days, stored as `yyyy-MM-dd` so they stay the
  /// same day in every time zone.
  static String _formatDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  /// Reads `yyyy-MM-dd` as local midnight. A full timestamp is converted to
  /// local time first and keeps that day.
  static DateTime? _parseDay(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return DateTime(local.year, local.month, local.day);
  }

  static bool _sameMoment(DateTime? a, DateTime? b) =>
      a == null ? b == null : b != null && a.isAtSameMomentAs(b);
}

abstract final class _Keys {
  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const categoryId = 'categoryId';
  static const resourceId = 'resourceId';
  static const priority = 'priority';
  static const status = 'status';
  static const dueDate = 'dueDate';
  static const completedAt = 'completedAt';
  static const isFavorite = 'isFavorite';
  static const tags = 'tags';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
