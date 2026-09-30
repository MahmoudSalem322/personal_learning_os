import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_guard.dart';
import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../notifications/domain/app_notification.dart';
import '../../reminders/domain/reminder.dart';
import '../../resources/domain/resource.dart';
import '../../settings/data/local_settings_repository.dart';
import '../../settings/domain/app_settings.dart';
import '../../tasks/domain/task.dart';
import '../domain/backup_snapshot.dart';
import '../domain/backup_store.dart';

/// [BackupStore] over the local sembast database.
class LocalBackupStore implements BackupStore {
  LocalBackupStore(this._db);

  final Database _db;

  static final _settingsRecord = AppStores.settings.record(
    LocalSettingsRepository.recordKey,
  );

  @override
  Future<BackupSnapshot> read() => guardStorage('read all data', () async {
    Future<List<T>> all<T>(
      StoreRef<String, Map<String, Object?>> store,
      String kind,
      T Function(Map<String, Object?>) fromJson,
    ) async => [
      for (final record in await store.find(_db))
        ?tryParseRecord(kind, record.value, fromJson),
    ];

    final settings = await _settingsRecord.get(_db);
    return BackupSnapshot(
      settings: settings == null
          ? AppSettings.defaults
          : AppSettings.fromJson(settings),
      categories: await all(
        AppStores.categories,
        'category',
        Category.fromJson,
      ),
      resources: await all(AppStores.resources, 'resource', Resource.fromJson),
      notes: await all(AppStores.notes, 'note', Note.fromJson),
      tasks: await all(AppStores.tasks, 'task', Task.fromJson),
      reminders: await all(AppStores.reminders, 'reminder', Reminder.fromJson),
      notifications: await all(
        AppStores.notifications,
        'notification',
        AppNotification.fromJson,
      ),
    );
  });

  @override
  Future<void> replaceAll(BackupSnapshot snapshot) =>
      guardStorage('restore data', () {
        return _db.transaction((txn) async {
          Future<void> write<T>(
            StoreRef<String, Map<String, Object?>> store,
            List<T> items,
            String Function(T) idOf,
            Map<String, Object?> Function(T) toJson,
          ) async {
            await store.delete(txn);
            for (final item in items) {
              await store.record(idOf(item)).put(txn, toJson(item));
            }
          }

          await _settingsRecord.put(txn, snapshot.settings.toJson());
          await write(
            AppStores.categories,
            snapshot.categories,
            (c) => c.id,
            (c) => c.toJson(),
          );
          await write(
            AppStores.resources,
            snapshot.resources,
            (r) => r.id,
            (r) => r.toJson(),
          );
          await write(
            AppStores.notes,
            snapshot.notes,
            (n) => n.id,
            (n) => n.toJson(),
          );
          await write(
            AppStores.tasks,
            snapshot.tasks,
            (t) => t.id,
            (t) => t.toJson(),
          );
          await write(
            AppStores.reminders,
            snapshot.reminders,
            (r) => r.id,
            (r) => r.toJson(),
          );
          await write(
            AppStores.notifications,
            snapshot.notifications,
            (n) => n.id,
            (n) => n.toJson(),
          );
        });
      });
}
