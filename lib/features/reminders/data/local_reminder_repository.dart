import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';

/// [ReminderRepository] backed by the local sembast database.
class LocalReminderRepository implements ReminderRepository {
  LocalReminderRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.reminders,
        kind: 'reminder',
        fromJson: Reminder.fromJson,
        toJson: (r) => r.toJson(),
        idOf: (r) => r.id,
        compare: (a, b) => a.remindAt.compareTo(b.remindAt),
      );

  final LocalDocumentStore<Reminder> _docs;

  @override
  Stream<List<Reminder>> watchAll() => _docs.watchAll();

  @override
  Future<List<Reminder>> getAll() => _docs.getAll();

  @override
  Future<Reminder?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(Reminder reminder) => _docs.save(reminder);

  @override
  Future<void> saveAll(Iterable<Reminder> reminders) =>
      _docs.saveAll(reminders);

  @override
  Future<void> delete(String id) => _docs.delete(id);

  @override
  Future<void> deleteAll(Iterable<String> ids) => _docs.deleteAll(ids);
}
