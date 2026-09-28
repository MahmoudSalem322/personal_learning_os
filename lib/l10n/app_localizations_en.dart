// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learning OS';

  @override
  String get appTagline => 'Personal learning workspace';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCategories => 'Categories';

  @override
  String get navResources => 'Resources';

  @override
  String get navNotes => 'Notes';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get navOpenMenu => 'Open navigation menu';

  @override
  String get navMainLabel => 'Main navigation';

  @override
  String get dashboardSubtitle => 'Your learning at a glance.';

  @override
  String get categoriesSubtitle => 'Organize your learning into focused areas.';

  @override
  String get resourcesSubtitle =>
      'Courses, videos, docs and articles in one library.';

  @override
  String get notesSubtitle => 'Capture what you learn, in your own words.';

  @override
  String get tasksSubtitle => 'Plan and track the next steps of your learning.';

  @override
  String get favoritesSubtitle => 'Everything you starred, in one place.';

  @override
  String get settingsSubtitle => 'Personalize how Learning OS looks and works.';

  @override
  String comingSoonTitle(String section) {
    return '$section is on its way';
  }

  @override
  String get comingSoonMessage =>
      'This space is part of an upcoming phase. The foundation is ready, and it will appear here soon.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage =>
      'The page you are looking for doesn\'t exist or may have been moved.';

  @override
  String get notFoundAction => 'Back to dashboard';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericMessage =>
      'An unexpected error occurred. Please try again.';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get storageVolatileWarning =>
      'Local storage is unavailable in this browser session. Your changes won\'t be kept after you close this tab.';

  @override
  String get settingsSaveError =>
      'Couldn\'t save your preference. Please try again.';
}
