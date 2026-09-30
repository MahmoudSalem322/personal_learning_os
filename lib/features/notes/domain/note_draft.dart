import 'package:flutter/foundation.dart' show immutable;

import '../../../core/errors/app_exception.dart';
import '../../tags/domain/tags.dart';
import 'note.dart';

/// The editable parts of a note, as the editor holds them.
///
/// Favorites are not part of it: starring is saved on its own so an
/// in-flight autosave can never undo it.
@immutable
class NoteDraft {
  const NoteDraft({
    this.title = '',
    this.content = '',
    this.categoryId,
    this.resourceId,
    this.tags = const [],
  });

  factory NoteDraft.fromNote(Note note) => NoteDraft(
    title: note.title,
    content: note.content,
    categoryId: note.categoryId,
    resourceId: note.resourceId,
    tags: note.tags,
  );

  final String title;
  final String content;
  final String? categoryId;
  final String? resourceId;
  final List<String> tags;

  /// Title trimmed (content is kept as typed: whitespace matters in
  /// Markdown), tags normalized.
  NoteDraft normalized() => NoteDraft(
    title: title.trim().replaceAll(RegExp(r'\s+'), ' '),
    content: content,
    categoryId: categoryId,
    resourceId: resourceId,
    tags: TagRules.normalizeAll(tags),
  );
}

/// Limits for note fields.
abstract final class NoteRules {
  static const int titleMaxLength = 200;

  /// Generous but bounded, so one runaway paste can't bloat storage.
  static const int contentMaxLength = 100000;
}

enum NoteFieldError { titleTooLong, contentTooLong, tooManyTags }

/// Thrown by `NoteService` when a draft is invalid.
final class NoteValidationException extends AppException {
  NoteValidationException(this.errors)
    : super('Invalid note: ${errors.map((e) => e.name).join(', ')}');

  final Set<NoteFieldError> errors;
}
