import 'package:flutter/foundation.dart' show immutable;

import '../../notifications/domain/notification_preferences.dart';

/// Preferred color scheme.
enum ThemePreference { system, light, dark }

/// Preferred UI language. [system] follows the browser language.
enum AppLanguage {
  system(null),
  english('en'),
  arabic('ar');

  const AppLanguage(this.languageCode);

  /// ISO 639-1 code, or `null` to follow the system.
  final String? languageCode;
}

/// User preferences that apply to the whole app.
@immutable
class AppSettings {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.language = AppLanguage.system,
    this.notifications = NotificationPreferences.defaults,
  });

  /// Rebuilds settings from stored JSON. Unknown or missing values fall back
  /// to defaults, so older or partially corrupted data never crashes the app.
  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      themePreference: _enumByName(
        ThemePreference.values,
        json[_Keys.themePreference],
        defaults.themePreference,
      ),
      language: _enumByName(
        AppLanguage.values,
        json[_Keys.language],
        defaults.language,
      ),
      notifications: NotificationPreferences.fromJson(
        json[_Keys.notifications],
      ),
    );
  }

  static const AppSettings defaults = AppSettings();

  final ThemePreference themePreference;
  final AppLanguage language;
  final NotificationPreferences notifications;

  AppSettings copyWith({
    ThemePreference? themePreference,
    AppLanguage? language,
    NotificationPreferences? notifications,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.themePreference: themePreference.name,
    _Keys.language: language.name,
    _Keys.notifications: notifications.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themePreference == themePreference &&
      other.language == language &&
      other.notifications == notifications;

  @override
  int get hashCode => Object.hash(themePreference, language, notifications);

  @override
  String toString() =>
      'AppSettings(themePreference: ${themePreference.name}, '
      'language: ${language.name})';

  static T _enumByName<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    if (raw is! String) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}

abstract final class _Keys {
  static const themePreference = 'themePreference';
  static const language = 'language';
  static const notifications = 'notifications';
}
