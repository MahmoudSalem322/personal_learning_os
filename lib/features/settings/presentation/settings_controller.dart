import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../notifications/domain/notification_preferences.dart';
import '../data/local_settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Settings read during bootstrap, so the first frame already uses the
/// user's theme and language (no flash of the default theme).
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => AppSettings.defaults,
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Holds the current [AppSettings] and persists every change.
///
/// Updates are optimistic: the UI changes immediately and is rolled back if
/// saving fails. Failures are rethrown as `StorageException` so the caller
/// can show feedback.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> setThemePreference(ThemePreference value) =>
      _update(state.copyWith(themePreference: value));

  Future<void> setLanguage(AppLanguage value) =>
      _update(state.copyWith(language: value));

  Future<void> setNotificationPreferences(NotificationPreferences value) =>
      _update(state.copyWith(notifications: value));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    final previous = state;
    state = next;
    try {
      await ref.read(settingsRepositoryProvider).save(next);
    } catch (_) {
      if (ref.mounted) state = previous;
      rethrow;
    }
  }
}
