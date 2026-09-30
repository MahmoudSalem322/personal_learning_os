import 'app_notification.dart';

/// A way of telling the user about new notifications, besides the inbox.
///
/// The app ships an in-app channel (a toast while the app is open). A
/// browser channel (Web Notifications API) can implement this later
/// without changing the engine.
abstract interface class NotificationChannel {
  /// Called with the notifications just created, oldest first. Must not
  /// throw; a failing channel never blocks the others.
  Future<void> deliver(List<AppNotification> notifications);
}
