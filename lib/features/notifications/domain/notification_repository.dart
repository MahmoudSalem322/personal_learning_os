import 'app_notification.dart';

/// Persistence for [AppNotification] records, dismissed ones included.
///
/// Implementations throw `StorageException` on failure. Lists are newest
/// first.
abstract interface class NotificationRepository {
  /// Emits the current list immediately and again after every change.
  Stream<List<AppNotification>> watchAll();

  Future<List<AppNotification>> getAll();

  Future<AppNotification?> getById(String id);

  Future<void> save(AppNotification notification);

  Future<void> saveAll(Iterable<AppNotification> notifications);

  Future<void> deleteAll(Iterable<String> ids);
}
