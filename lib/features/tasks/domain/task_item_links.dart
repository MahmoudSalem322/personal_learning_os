import 'package:flutter/foundation.dart' show immutable;

import 'task.dart';

/// Something that can reference a task (notes). Implemented by those
/// features, so the tasks domain doesn't depend on them.
///
/// Deleting a task keeps the referencing items and only removes the link;
/// Undo puts the same links back.
abstract interface class TaskItemLinks {
  /// Removes the link to [taskId] from every item; returns the ids of the
  /// items that were changed.
  Future<List<String>> detach(String taskId);

  /// Links the given items to [taskId] again.
  Future<void> reattach(String taskId, List<String> itemIds);
}

/// A deleted task plus the links removed with it, for Undo.
@immutable
class DeletedTask {
  const DeletedTask(this.task, this.detached);

  final Task task;

  /// Item ids unlinked from the task, per [TaskItemLinks] source (same
  /// order as the service's links).
  final List<List<String>> detached;
}
