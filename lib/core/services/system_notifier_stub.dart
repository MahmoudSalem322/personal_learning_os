import 'system_notifier.dart';

/// Android, tests and other platforms: in-app notifications only.
SystemNotifier createSystemNotifier() => const _UnsupportedSystemNotifier();

class _UnsupportedSystemNotifier implements SystemNotifier {
  const _UnsupportedSystemNotifier();

  @override
  bool get isSupported => false;

  @override
  bool get isAllowed => false;

  @override
  bool get appIsVisible => true;

  @override
  Future<bool> requestPermission() async => false;

  @override
  void show({required String title, required String body, String? tag}) {}
}
