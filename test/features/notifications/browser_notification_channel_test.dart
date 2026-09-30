import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_learning_os/core/services/system_notifier.dart';
import 'package:personal_learning_os/features/notifications/domain/app_notification.dart';
import 'package:personal_learning_os/features/notifications/domain/notification_preferences.dart';
import 'package:personal_learning_os/features/notifications/presentation/browser_notification_channel.dart';
import 'package:personal_learning_os/l10n/app_localizations_en.dart';

class _FakeNotifier implements SystemNotifier {
  bool allowed = true;
  bool visible = false;
  final List<({String title, String body})> shown = [];

  @override
  bool get isSupported => true;

  @override
  bool get isAllowed => allowed;

  @override
  bool get appIsVisible => visible;

  @override
  Future<bool> requestPermission() async => allowed;

  @override
  void show({required String title, required String body, String? tag}) =>
      shown.add((title: title, body: body));
}

AppNotification overdue(String id) => AppNotification(
  id: id,
  type: NotificationType.overdueTask,
  key: id,
  subject: 'Read the docs',
  target: NotificationTarget.task,
  targetId: 't',
  dueDate: DateTime(2026, 9, 28),
  createdAt: DateTime(2026, 9, 30),
);

void main() {
  late _FakeNotifier notifier;
  late NotificationPreferences prefs;
  late BrowserNotificationChannel channel;

  // The app loads date formats with its localizations; a unit test must.
  setUpAll(() => initializeDateFormatting('en'));

  setUp(() {
    notifier = _FakeNotifier();
    prefs = const NotificationPreferences(browser: true);
    channel = BrowserNotificationChannel(
      notifier: notifier,
      preferences: () => prefs,
      localizations: () => (AppLocalizationsEn(), 'en'),
    );
  });

  test(
    'shows localized notifications while the app is in the background',
    () async {
      await channel.deliver([overdue('a')]);
      expect(notifier.shown.single.title, 'Overdue task');
      expect(
        notifier.shown.single.body,
        '"Read the docs" was due Sep 28, 2026',
      );
    },
  );

  test('stays quiet when visible, not allowed or turned off', () async {
    notifier.visible = true;
    await channel.deliver([overdue('a')]);
    notifier
      ..visible = false
      ..allowed = false;
    await channel.deliver([overdue('b')]);
    notifier.allowed = true;
    prefs = const NotificationPreferences();
    await channel.deliver([overdue('c')]);
    expect(notifier.shown, isEmpty);
  });

  test('many at once become one summary', () async {
    await channel.deliver([for (var i = 0; i < 5; i++) overdue('n$i')]);
    expect(notifier.shown.single.body, '5 new notifications');
  });

  test('the preference is off by default and survives a round trip', () {
    expect(NotificationPreferences.defaults.browser, isFalse);
    expect(
      NotificationPreferences.fromJson(
        const NotificationPreferences(browser: true).toJson(),
      ).browser,
      isTrue,
    );
  });
}
