import '../../../core/services/system_notifier.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_notification.dart';
import '../domain/notification_channel.dart';
import '../domain/notification_preferences.dart';
import 'notification_appearance.dart';

/// Shows new notifications through the browser (or OS) while the app is in
/// the background, when the user turned it on and allowed it.
class BrowserNotificationChannel implements NotificationChannel {
  BrowserNotificationChannel({
    required this.notifier,
    required this.preferences,
    required this.localizations,
  });

  /// More than this many at once become one summary notification.
  static const int maxSeparate = 3;

  final SystemNotifier notifier;
  final NotificationPreferences Function() preferences;

  /// Strings and the locale for dates, in the app's current language.
  final (AppLocalizations, String) Function() localizations;

  @override
  Future<void> deliver(List<AppNotification> notifications) async {
    final prefs = preferences();
    if (!prefs.enabled ||
        !prefs.browser ||
        !notifier.isAllowed ||
        notifier.appIsVisible) {
      return;
    }
    final (l10n, locale) = localizations();
    if (notifications.length > maxSeparate) {
      notifier.show(
        title: l10n.appTitle,
        body: l10n.notificationsNewCount(notifications.length),
        tag: 'qabas-summary',
      );
      return;
    }
    for (final n in notifications) {
      notifier.show(
        title: n.titleIn(l10n),
        body: n.bodyIn(l10n, locale),
        tag: n.id,
      );
    }
  }
}
