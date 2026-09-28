import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';

/// Maps domain preferences to Flutter types and localized labels.
extension ThemePreferenceX on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  IconData get icon => switch (this) {
    ThemePreference.system => Icons.contrast_rounded,
    ThemePreference.light => Icons.light_mode_outlined,
    ThemePreference.dark => Icons.dark_mode_outlined,
  };

  String label(AppLocalizations l10n) => switch (this) {
    ThemePreference.system => l10n.themeSystem,
    ThemePreference.light => l10n.themeLight,
    ThemePreference.dark => l10n.themeDark,
  };
}

extension AppLanguageX on AppLanguage {
  /// `null` lets Flutter resolve the locale from the browser.
  Locale? get locale => switch (languageCode) {
    final code? => Locale(code),
    null => null,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.system => l10n.languageSystem,
    AppLanguage.english => l10n.languageEnglish,
    AppLanguage.arabic => l10n.languageArabic,
  };
}
