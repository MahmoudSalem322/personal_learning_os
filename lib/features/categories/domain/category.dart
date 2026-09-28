import 'package:flutter/foundation.dart' show immutable;

/// A learning area such as "Flutter", "Dart" or "UI/UX".
///
/// Resources, notes and tasks will reference a category by [id]. Aggregates
/// such as counts and progress are computed, never stored here.
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
  });

  /// Parses a stored record. Throws [FormatException] when required fields
  /// are missing or have the wrong type; callers decide whether to skip the
  /// record or fail.
  factory Category.fromJson(Map<String, Object?> json) {
    T read<T>(String key) {
      final value = json[key];
      if (value is T) return value;
      throw FormatException('Category.$key: expected $T, got $value');
    }

    DateTime readDate(String key) {
      final parsed = DateTime.tryParse(read<String>(key));
      if (parsed == null) throw FormatException('Category.$key: bad date');
      return parsed;
    }

    return Category(
      id: read<String>(_Keys.id),
      name: read<String>(_Keys.name),
      description: json[_Keys.description] is String
          ? json[_Keys.description]! as String
          : '',
      icon: read<String>(_Keys.icon),
      primaryColor: read<int>(_Keys.primaryColor),
      secondaryColor: read<int>(_Keys.secondaryColor),
      createdAt: readDate(_Keys.createdAt),
      updatedAt: readDate(_Keys.updatedAt),
    );
  }

  final String id;
  final String name;
  final String description;

  /// Key into the category icon set (e.g. `code`, `palette`).
  final String icon;

  /// Identity colors as 32-bit ARGB values.
  final int primaryColor;
  final int secondaryColor;

  final DateTime createdAt;
  final DateTime updatedAt;

  Category copyWith({
    String? name,
    String? description,
    String? icon,
    int? primaryColor,
    int? secondaryColor,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.name: name,
    _Keys.description: description,
    _Keys.icon: icon,
    _Keys.primaryColor: primaryColor,
    _Keys.secondaryColor: secondaryColor,
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.icon == icon &&
      other.primaryColor == primaryColor &&
      other.secondaryColor == secondaryColor &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    icon,
    primaryColor,
    secondaryColor,
    createdAt.millisecondsSinceEpoch,
    updatedAt.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Category($id, $name)';
}

abstract final class _Keys {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const icon = 'icon';
  static const primaryColor = 'primaryColor';
  static const secondaryColor = 'secondaryColor';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
