import 'package:flutter/foundation.dart' show immutable;

import '../../../core/errors/app_exception.dart';
import '../../tags/domain/tags.dart';
import 'task.dart';

/// The editable parts of a task, as the form holds them.
@immutable
class TaskDraft {
  const TaskDraft({
    this.title = '',
    this.description = '',
    this.categoryId,
    this.resourceId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.tags = const [],
  });

  factory TaskDraft.fromTask(Task task) => TaskDraft(
    title: task.title,
    description: task.description,
    categoryId: task.categoryId,
    resourceId: task.resourceId,
    priority: task.priority,
    status: task.status,
    dueDate: task.dueDate,
    tags: task.tags,
  );

  final String title;
  final String description;
  final String? categoryId;
  final String? resourceId;
  final TaskPriority priority;
  final TaskStatus status;

  /// Date-only due day, at local midnight.
  final DateTime? dueDate;
  final List<String> tags;

  /// Title and description trimmed, tags normalized.
  TaskDraft normalized() => TaskDraft(
    title: title.trim().replaceAll(RegExp(r'\s+'), ' '),
    description: description.trim(),
    categoryId: categoryId,
    resourceId: resourceId,
    priority: priority,
    status: status,
    dueDate: dueDate == null
        ? null
        : DateTime(dueDate!.year, dueDate!.month, dueDate!.day),
    tags: TagRules.normalizeAll(tags),
  );
}

/// Limits for task fields.
abstract final class TaskRules {
  static const int titleMaxLength = 120;
  static const int descriptionMaxLength = 2000;
}

/// Why a [TaskDraft] was rejected.
enum TaskFieldError {
  titleRequired,
  titleTooLong,
  descriptionTooLong,
  tooManyTags,
}

/// Thrown by `TaskService` when a draft is invalid.
final class TaskValidationException extends AppException {
  TaskValidationException(this.errors)
    : super('Invalid task: ${errors.map((e) => e.name).join(', ')}');

  final Set<TaskFieldError> errors;
}
