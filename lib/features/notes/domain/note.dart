import 'package:flutter/foundation.dart' show immutable, listEquals;

/// A note written in Markdown. It can stand alone or be linked to a
/// category and/or a resource.
@immutable
class Note {
  Note({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.title = '',
    this.content = '',
    this.categoryId,
    this.resourceId,
    this.taskId,
    List<String> tags = const [],
    this.isFavorite = false,
  }) : tags = List.unmodifiable(tags);

  /// Parses a stored record. Missing required fields (id, dates) throw
  /// [FormatException]; everything else falls back to defaults.
  factory Note.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('Note.$key: expected String, got $value');
    }

    DateTime readDate(String key) {
      final parsed = DateTime.tryParse(readString(key));
      if (parsed == null) throw FormatException('Note.$key: bad date');
      return parsed;
    }

    String optional(String key) =>
        json[key] is String ? json[key]! as String : '';

    String? optionalId(String key) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    final rawTags = json[_Keys.tags];
    return Note(
      id: readString(_Keys.id),
      title: optional(_Keys.title),
      content: optional(_Keys.content),
      categoryId: optionalId(_Keys.categoryId),
      resourceId: optionalId(_Keys.resourceId),
      taskId: optionalId(_Keys.taskId),
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      isFavorite: json[_Keys.isFavorite] == true,
      createdAt: readDate(_Keys.createdAt),
      updatedAt: readDate(_Keys.updatedAt),
    );
  }

  final String id;

  /// May be empty; the UI shows "Untitled".
  final String title;

  /// Markdown source.
  final String content;
  final String? categoryId;
  final String? resourceId;

  /// The task this note belongs to, if any.
  final String? taskId;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nothing written yet: such notes are discarded when left.
  bool get isBlank => title.trim().isEmpty && content.trim().isEmpty;

  static const Object _unset = Object();

  /// Pass `null` for [categoryId], [resourceId] or [taskId] to remove the
  /// link.
  Note copyWith({
    String? title,
    String? content,
    Object? categoryId = _unset,
    Object? resourceId = _unset,
    Object? taskId = _unset,
    List<String>? tags,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      resourceId: identical(resourceId, _unset)
          ? this.resourceId
          : resourceId as String?,
      taskId: identical(taskId, _unset) ? this.taskId : taskId as String?,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.title: title,
    _Keys.content: content,
    _Keys.categoryId: categoryId,
    _Keys.resourceId: resourceId,
    _Keys.taskId: taskId,
    _Keys.tags: tags,
    _Keys.isFavorite: isFavorite,
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Note &&
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.categoryId == categoryId &&
      other.resourceId == resourceId &&
      other.taskId == taskId &&
      listEquals(other.tags, tags) &&
      other.isFavorite == isFavorite &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    categoryId,
    resourceId,
    taskId,
    Object.hashAll(tags),
    isFavorite,
    createdAt.millisecondsSinceEpoch,
    updatedAt.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Note($id, $title)';
}

abstract final class _Keys {
  static const id = 'id';
  static const title = 'title';
  static const content = 'content';
  static const categoryId = 'categoryId';
  static const resourceId = 'resourceId';
  static const taskId = 'taskId';
  static const tags = 'tags';
  static const isFavorite = 'isFavorite';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
