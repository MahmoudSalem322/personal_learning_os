import 'reminder.dart';

/// Persistence for [Reminder] records.
///
/// Implementations throw `StorageException` on failure. Lists are sorted by
/// next fire time, soonest first.
abstract interface class ReminderRepository {
  /// Emits the current list immediately and again after every change.
  Stream<List<Reminder>> watchAll();

  Future<List<Reminder>> getAll();

  Future<Reminder?> getById(String id);

  /// Inserts or replaces the reminder with the same id.
  Future<void> save(Reminder reminder);

  Future<void> saveAll(Iterable<Reminder> reminders);

  Future<void> delete(String id);

  Future<void> deleteAll(Iterable<String> ids);
}
