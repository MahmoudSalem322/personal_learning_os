import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults follow the system theme and language', () {
      const settings = AppSettings.defaults;
      expect(settings.themePreference, ThemePreference.system);
      expect(settings.language, AppLanguage.system);
    });

    test('round-trips through JSON', () {
      const settings = AppSettings(
        themePreference: ThemePreference.dark,
        language: AppLanguage.arabic,
      );
      expect(AppSettings.fromJson(settings.toJson()), settings);
    });

    test('falls back to defaults for unknown or malformed values', () {
      final settings = AppSettings.fromJson({
        'themePreference': 'neon',
        'language': 42,
      });
      expect(settings, AppSettings.defaults);
    });

    test('falls back to defaults for missing keys', () {
      expect(AppSettings.fromJson(const {}), AppSettings.defaults);
    });

    test('copyWith replaces only the given fields', () {
      final updated = AppSettings.defaults.copyWith(
        themePreference: ThemePreference.light,
      );
      expect(updated.themePreference, ThemePreference.light);
      expect(updated.language, AppLanguage.system);
    });

    test('value equality', () {
      expect(
        const AppSettings(themePreference: ThemePreference.dark),
        const AppSettings(themePreference: ThemePreference.dark),
      );
      expect(
        const AppSettings(themePreference: ThemePreference.dark).hashCode,
        const AppSettings(themePreference: ThemePreference.dark).hashCode,
      );
    });
  });

  test('AppLanguage exposes language codes', () {
    expect(AppLanguage.system.languageCode, isNull);
    expect(AppLanguage.english.languageCode, 'en');
    expect(AppLanguage.arabic.languageCode, 'ar');
  });
}
