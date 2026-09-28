import 'package:flutter/foundation.dart' show immutable;

import '../../../core/errors/app_exception.dart';
import 'category.dart';

/// User input for creating or editing a category, before validation.
@immutable
class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.description = '',
  });

  factory CategoryDraft.fromCategory(Category category) => CategoryDraft(
    name: category.name,
    description: category.description,
    icon: category.icon,
    primaryColor: category.primaryColor,
    secondaryColor: category.secondaryColor,
  );

  final String name;
  final String description;
  final String icon;
  final int primaryColor;
  final int secondaryColor;

  /// Copy with surrounding whitespace removed and inner runs of spaces in the
  /// name collapsed, so "  Flutter   Web " is stored as "Flutter Web".
  CategoryDraft normalized() => CategoryDraft(
    name: name.trim().replaceAll(RegExp(r'\s+'), ' '),
    description: description.trim(),
    icon: icon,
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
}

/// Limits for category fields.
abstract final class CategoryRules {
  static const int nameMaxLength = 40;
  static const int descriptionMaxLength = 200;
}

/// Why a [CategoryDraft] was rejected.
enum CategoryFieldError {
  nameRequired,
  nameTooLong,
  nameTaken,
  descriptionTooLong,
}

/// Thrown by `CategoryService` when a draft is invalid.
final class CategoryValidationException extends AppException {
  CategoryValidationException(this.errors)
    : super('Invalid category: ${errors.map((e) => e.name).join(', ')}');

  final Set<CategoryFieldError> errors;
}
