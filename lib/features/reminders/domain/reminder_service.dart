import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import 'reminder.dart';
import 'reminder_draft.dart';
import 'reminder_repository.dart';

/// Use cases for reminders: validation, ids, timestamps, pause/resume and
/// delete + restore.
class ReminderService {
  ReminderService(
    this._repository, {
    IdGenerator? ids,
    DateTime Function()? clock,
  }) : _ids = ids ?? IdGenerator(),
       _clock = clock ?? DateTime.now;

  final ReminderRepository _repository;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Every rule [draft] breaks at [now] (after normalization).
  static Set<ReminderFieldError> validate(ReminderDraft draft, DateTime now) {
    final d = draft.normalized();
    return {
      if (d.target == ReminderTarget.session && d.title.isEmpty)
        ReminderFieldError.titleRequired,
      if (d.title.length > ReminderRules.titleMaxLength)
        ReminderFieldError.titleTooLong,
      if (d.target != ReminderTarget.session && d.targetId == null)
        ReminderFieldError.targetRequired,
      if (d.repeat == ReminderRepeat.none && !d.remindAt.isAfter(now))
        ReminderFieldError.timeInPast,
    };
  }

  Future<Reminder> create(ReminderDraft draft) async {
    final now = _clock();
    final d = _validated(draft, now);
    final reminder = _upcoming(
      Reminder(
        id: _ids.next(),
        target: d.target,
        targetId: d.targetId,
        title: d.title,
        remindAt: d.remindAt,
        repeat: d.repeat,
        createdAt: now,
        updatedAt: now,
      ),
      now,
    );
    await _repository.save(reminder);
    return reminder;
  }

  /// Saves the edit and re-arms the reminder (a finished one-off reminder
  /// moved to a new time fires again).
  Future<Reminder> update(String id, ReminderDraft draft) async {
    final current = await _require(id);
    final now = _clock();
    final d = _validated(draft, now);
    final updated = _upcoming(
      current.copyWith(
        target: d.target,
        targetId: d.targetId,
        title: d.title,
        remindAt: d.remindAt,
        repeat: d.repeat,
        lastFiredAt: null,
        updatedAt: now,
      ),
      now,
    );
    await _repository.save(updated);
    return updated;
  }

  /// Pauses or resumes. Resuming a repeating reminder skips the
  /// occurrences missed while paused.
  Future<Reminder> setEnabled(String id, {required bool enabled}) async {
    final current = await _require(id);
    if (current.isEnabled == enabled) return current;
    final now = _clock();
    final updated = current.copyWith(isEnabled: enabled, updatedAt: now);
    final saved = enabled ? _upcoming(updated, now) : updated;
    await _repository.save(saved);
    return saved;
  }

  /// Deletes the reminder and returns it so the caller can offer Undo.
  Future<Reminder> delete(String id) async {
    final current = await _require(id);
    await _repository.delete(id);
    return current;
  }

  Future<void> restore(Reminder reminder) => _repository.save(reminder);

  /// A repeating reminder set in the past starts at its next occurrence.
  static Reminder _upcoming(Reminder r, DateTime now) =>
      r.isRepeating && !r.remindAt.isAfter(now)
      ? r.copyWith(remindAt: r.nextAfter(now))
      : r;

  ReminderDraft _validated(ReminderDraft draft, DateTime now) {
    final errors = validate(draft, now);
    if (errors.isNotEmpty) throw ReminderValidationException(errors);
    return draft.normalized();
  }

  Future<Reminder> _require(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Reminder $id not found');
    return current;
  }
}
