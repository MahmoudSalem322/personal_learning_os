import 'package:sembast/sembast.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/local_document_store.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

/// [NotificationRepository] backed by the local sembast database.
class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository(Database db)
    : _docs = LocalDocumentStore(
        db: db,
        store: AppStores.notifications,
        kind: 'notification',
        fromJson: AppNotification.fromJson,
        toJson: (n) => n.toJson(),
        idOf: (n) => n.id,
        compare: (a, b) => b.createdAt.compareTo(a.createdAt),
      );

  final LocalDocumentStore<AppNotification> _docs;

  @override
  Stream<List<AppNotification>> watchAll() => _docs.watchAll();

  @override
  Future<List<AppNotification>> getAll() => _docs.getAll();

  @override
  Future<AppNotification?> getById(String id) => _docs.getById(id);

  @override
  Future<void> save(AppNotification notification) => _docs.save(notification);

  @override
  Future<void> saveAll(Iterable<AppNotification> notifications) =>
      _docs.saveAll(notifications);

  @override
  Future<void> deleteAll(Iterable<String> ids) => _docs.deleteAll(ids);
}
