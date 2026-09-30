import 'dart:async';

import '../domain/app_notification.dart';
import '../domain/notification_channel.dart';

/// Hands new notifications to the open app (which shows a toast).
class InAppNotificationChannel implements NotificationChannel {
  final StreamController<List<AppNotification>> _controller =
      StreamController.broadcast();

  /// New notifications, one event per engine run that created any.
  Stream<List<AppNotification>> get delivered => _controller.stream;

  @override
  Future<void> deliver(List<AppNotification> notifications) async {
    if (!_controller.isClosed) _controller.add(notifications);
  }

  Future<void> dispose() => _controller.close();
}
