import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/system_notifier.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../reminders/presentation/reminders_providers.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../data/in_app_notification_channel.dart';
import '../data/local_notification_repository.dart';
import '../domain/app_notification.dart';
import '../domain/notification_engine.dart';
import '../domain/notification_repository.dart';
import '../domain/notification_service.dart';
import 'browser_notification_channel.dart';
import 'notification_scheduler.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => LocalNotificationRepository(ref.watch(appDatabaseProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(notificationRepositoryProvider)),
);

/// Every stored notification, newest first, dismissed ones included.
final notificationsProvider = StreamProvider<List<AppNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).watchAll(),
);

/// The inbox: notifications that weren't dismissed, newest first.
final inboxProvider = Provider<AsyncValue<List<AppNotification>>>(
  (ref) => ref
      .watch(notificationsProvider)
      .whenData(
        (all) => [
          for (final n in all)
            if (!n.isDismissed) n,
        ],
      ),
);

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(inboxProvider).value?.where((n) => !n.isRead).length ?? 0,
);

/// In-app delivery: the shell shows a toast for new notifications.
final inAppNotificationChannelProvider = Provider<InAppNotificationChannel>((
  ref,
) {
  final channel = InAppNotificationChannel();
  ref.onDispose(channel.dispose);
  return channel;
});

final notificationEngineProvider = Provider<NotificationEngine>(
  (ref) => NotificationEngine(
    notifications: ref.watch(notificationRepositoryProvider),
    reminders: ref.watch(reminderRepositoryProvider),
    tasks: ref.watch(taskRepositoryProvider),
    resources: ref.watch(resourceRepositoryProvider),
    preferences: () => ref.read(settingsControllerProvider).notifications,
    channels: [
      ref.watch(inAppNotificationChannelProvider),
      BrowserNotificationChannel(
        notifier: ref.watch(systemNotifierProvider),
        preferences: () => ref.read(settingsControllerProvider).notifications,
        localizations: () {
          final language = ref.read(settingsControllerProvider).language;
          final code =
              language.languageCode ??
              PlatformDispatcher.instance.locale.languageCode;
          final locale =
              AppLocalizations.supportedLocales.any(
                (l) => l.languageCode == code,
              )
              ? Locale(code)
              : const Locale('en');
          return (lookupAppLocalizations(locale), locale.toLanguageTag());
        },
      ),
    ],
  ),
);

/// Whether the background scheduler runs. Widget tests turn it off and
/// drive [NotificationEngine.run] themselves.
final notificationSchedulingEnabledProvider = Provider<bool>((ref) => true);

/// Runs the engine while the app is open: shortly after start, every
/// minute, and after tasks, reminders or preferences change.
final notificationSchedulerProvider = Provider<NotificationScheduler?>((ref) {
  if (!ref.watch(notificationSchedulingEnabledProvider)) return null;
  final scheduler = NotificationScheduler(ref.watch(notificationEngineProvider))
    ..start();
  ref
    ..onDispose(scheduler.dispose)
    ..listen(tasksProvider, (_, _) => scheduler.requestRun())
    ..listen(remindersProvider, (_, _) => scheduler.requestRun())
    ..listen(
      settingsControllerProvider.select((s) => s.notifications),
      (_, _) => scheduler.requestRun(),
    );
  return scheduler;
});
