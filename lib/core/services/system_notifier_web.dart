import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'system_notifier.dart';

SystemNotifier createSystemNotifier() => const _BrowserNotifier();

/// The browser's Notification API.
class _BrowserNotifier implements SystemNotifier {
  const _BrowserNotifier();

  @override
  bool get isSupported => web.window.has('Notification');

  @override
  bool get isAllowed => isSupported && web.Notification.permission == 'granted';

  @override
  bool get appIsVisible => web.document.visibilityState == 'visible';

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final result = await web.Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  void show({required String title, required String body, String? tag}) {
    if (!isAllowed) return;
    final notification = web.Notification(
      title,
      web.NotificationOptions(
        body: body,
        tag: tag ?? '',
        icon: 'icons/Icon-192.png',
      ),
    );
    // Clicking brings the app to the front.
    notification.onclick = ((web.Event _) {
      web.window.focus();
      notification.close();
    }).toJS;
  }
}
