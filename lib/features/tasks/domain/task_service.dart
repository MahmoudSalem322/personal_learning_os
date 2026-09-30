import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import '../../tags/domain/tags.dart';
import 'task.dart';
import 'task_draft.dart';
import 'task_repository.dart';

/// Use cases for tasks: validation, ids, timestamps, status changes
/// (including [Task.completedAt] bookkeeping) and delete + restore.
class TaskService {
  TaskService(this._repository, {IdGenerator? ids, DateTime Function()? clock})
    : _ids = ids ?? IdGenerator(),
      _clock = clock ?? DateTime.now;

  final TaskRepository _repository;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Returns every rule [draft] breaks (after normalization).
  static Set<TaskFieldError> validate(TaskDraft draft) {
    final d = draft.normalized();
    return {
      if (d.title.isEmpty) TaskFieldError.titleRequired,
      if (d.title.length > TaskRules.titleMaxLength)
        TaskFieldError.titleTooLong,
      if (d.description.length > TaskRules.descriptionMaxLength)
        TaskFieldError.descriptionTooLong,
      if (d.tags.length > TagRules.maxPerItem) TaskFieldError.tooManyTags,
    };
  }

  Future<Task> create(TaskDraft draft) async {
    final d = _validated(draft);
    final now = _clock();
    final task = Task(
      id: _ids.next(),
      title: d.title,
      description: d.description,
      categoryId: d.categoryId,
      resourceId: d.resourceId,
      priority: d.priority,
      status: d.status,
      dueDate: d.dueDate,
      completedAt: d.status == TaskStatus.completed ? now : null,
      tags: d.tags,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(task);
    return task;
  }

  Future<Task> update(String id, TaskDraft draft) async {
    final current = await _require(id);
    final d = _validated(draft);
    final now = _clock();
    final updated = current.copyWith(
      title: d.title,
      description: d.description,
      categoryId: d.categoryId,
      resourceId: d.resourceId,
      priority: d.priority,
      status: d.status,
      dueDate: d.dueDate,
      completedAt: _completedAt(current, d, now),
      tags: d.tags,
      updatedAt: now,
    );
    if (updated.copyWith(updatedAt: current.updatedAt) == current) {
      return current;
    }
    await _repository.save(updated);
    return updated;
  }

  /// Keeps the original completion time when the task stays completed,
  /// stamps a fresh one when it just became completed, and clears it when
  /// the task is reopened.
  static DateTime? _completedAt(Task current, TaskDraft d, DateTime now) {
    if (d.status != TaskStatus.completed) return null;
    return current.completedAt ?? now;
  }

  /// Moves a task to [status] in one tap, without a full edit.
  Future<Task> setStatus(String id, TaskStatus status) async {
    final current = await _require(id);
    if (current.status == status) return current;
    final updated = current.copyWith(
      status: status,
      completedAt: status == TaskStatus.completed
          ? (current.completedAt ?? _clock())
          : null,
      updatedAt: _clock(),
    );
    await _repository.save(updated);
    return updated;
  }

  /// Quick "done" toggle for the checkbox: completed ↔ previous status.
  Future<Task> toggleCompleted(String id) async {
    final current = await _require(id);
    return setStatus(
      id,
      current.isCompleted ? TaskStatus.todo : TaskStatus.completed,
    );
  }

  Future<Task> setFavorite(String id, {required bool favorite}) async {
    final current = await _require(id);
    if (current.isFavorite == favorite) return current;
    final updated = current.copyWith(isFavorite: favorite, updatedAt: _clock());
    await _repository.save(updated);
    return updated;
  }

  Future<Task> setPriority(String id, TaskPriority priority) async {
    final current = await _require(id);
    if (current.priority == priority) return current;
    final updated = current.copyWith(priority: priority, updatedAt: _clock());
    await _repository.save(updated);
    return updated;
  }

  Future<Task> setDueDate(String id, DateTime? dueDate) async {
    final current = await _require(id);
    final day = dueDate == null
        ? null
        : DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (_sameDay(current.dueDate, day)) return current;
    final updated = current.copyWith(dueDate: day, updatedAt: _clock());
    await _repository.save(updated);
    return updated;
  }

  /// Deletes the task and returns it so the caller can offer Undo.
  Future<Task> delete(String id) async {
    final current = await _require(id);
    await _repository.delete(id);
    return current;
  }

  Future<void> restore(Task task) => _repository.save(task);

  TaskDraft _validated(TaskDraft draft) {
    final errors = validate(draft);
    if (errors.isNotEmpty) throw TaskValidationException(errors);
    return draft.normalized();
  }

  Future<Task> _require(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Task $id not found');
    return current;
  }

  static bool _sameDay(DateTime? a, DateTime? b) => a == null
      ? b == null
      : b != null && a.year == b.year && a.month == b.month && a.day == b.day;
}
