import '../../../core/errors/app_exception.dart';
import 'app_notification.dart';
import 'notification_repository.dart';

/// Inbox actions: read state, dismiss (with Undo) and bulk operations.
class NotificationService {
  NotificationService(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final NotificationRepository _repository;
  final DateTime Function() _clock;

  Future<void> setRead(String id, {required bool read}) async {
    final current = await _require(id);
    if (current.isRead == read) return;
    await _repository.save(current.copyWith(readAt: read ? _clock() : null));
  }

  /// Marks every unread, visible notification as read.
  Future<void> markAllRead() async {
    final now = _clock();
    final unread = (await _repository.getAll()).where(
      (n) => !n.isRead && !n.isDismissed,
    );
    await _repository.saveAll([
      for (final n in unread) n.copyWith(readAt: now),
    ]);
  }

  /// Removes the notification from the inbox and returns it for Undo.
  Future<AppNotification> dismiss(String id) async {
    final current = await _require(id);
    await _repository.save(current.copyWith(dismissedAt: _clock()));
    return current;
  }

  /// Removes every visible notification and returns them for Undo.
  Future<List<AppNotification>> dismissAll() async {
    final now = _clock();
    final visible = [
      for (final n in await _repository.getAll())
        if (!n.isDismissed) n,
    ];
    await _repository.saveAll([
      for (final n in visible) n.copyWith(dismissedAt: now),
    ]);
    return visible;
  }

  /// Puts dismissed notifications back as they were.
  Future<void> restore(Iterable<AppNotification> notifications) =>
      _repository.saveAll(notifications);

  Future<AppNotification> _require(String id) async {
    final current = await _repository.getById(id);
    if (current == null) {
      throw NotFoundException('Notification $id not found');
    }
    return current;
  }
}
