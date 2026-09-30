import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'system_notifier_stub.dart'
    if (dart.library.js_interop) 'system_notifier_web.dart'
    as platform;

/// The operating system's notifications (the browser's Notification API on
/// the web). Abstracted so features and tests don't depend on it.
abstract interface class SystemNotifier {
  /// Whether this platform can show system notifications at all.
  bool get isSupported;

  /// Whether the user allowed them.
  bool get isAllowed;

  /// Whether the app is on screen (no need to notify outside it then).
  bool get appIsVisible;

  /// Asks the user for permission; `true` when allowed.
  Future<bool> requestPermission();

  void show({required String title, required String body, String? tag});
}

final systemNotifierProvider = Provider<SystemNotifier>(
  (ref) => platform.createSystemNotifier(),
);
