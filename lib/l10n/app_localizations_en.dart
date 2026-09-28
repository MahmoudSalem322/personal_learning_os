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

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save changes';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionClose => 'Close';

  @override
  String get actionMore => 'More actions';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String validationTooLong(int max) {
    return 'Use $max characters or fewer';
  }

  @override
  String dateCreatedOn(String date) {
    return 'Created $date';
  }

  @override
  String dateUpdatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get categoriesNew => 'New category';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
      zero: 'No categories',
    );
    return '$_temp0';
  }

  @override
  String get categoriesSearchHint => 'Filter categories';

  @override
  String get categoriesEmptyTitle => 'Organize your learning';

  @override
  String get categoriesEmptyMessage =>
      'Categories are the areas you\'re learning, like Flutter, Dart or UI/UX. Create your first one to get started.';

  @override
  String get categoriesNoResultsTitle => 'No matching categories';

  @override
  String categoriesNoResultsMessage(String query) {
    return 'Nothing matches “$query”. Try a different name.';
  }

  @override
  String get categoryFormCreateTitle => 'New category';

  @override
  String get categoryFormEditTitle => 'Edit category';

  @override
  String get categoryFormName => 'Name';

  @override
  String get categoryFormNameHint => 'e.g. Flutter';

  @override
  String get categoryFormDescription => 'Description';

  @override
  String get categoryFormDescriptionHint =>
      'What are you learning in this area?';

  @override
  String get categoryFormIcon => 'Icon';

  @override
  String get categoryFormColor => 'Color';

  @override
  String get categoryFormPreviewName => 'Category name';

  @override
  String get categoryFormCreate => 'Create category';

  @override
  String get categoryNameRequired => 'Enter a name';

  @override
  String get categoryNameTaken => 'A category with this name already exists';

  @override
  String get categoryNoDescription => 'No description';

  @override
  String get categoryCreated => 'Category created';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categorySaveError =>
      'Couldn\'t save the category. Please try again.';

  @override
  String get categoryDeleteError =>
      'Couldn\'t delete the category. Please try again.';

  @override
  String categoryDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get categoryDeleteMessage =>
      'This category will be removed. You can undo this right after.';

  @override
  String get categoryNotFoundTitle => 'Category not found';

  @override
  String get categoryNotFoundMessage =>
      'It may have been deleted, or the link is incorrect.';

  @override
  String get categoryBackToList => 'All categories';

  @override
  String get categoryDetailEmptyTitle => 'Nothing here yet';

  @override
  String categoryDetailEmptyMessage(String name) {
    return 'Resources, notes and tasks you add to $name will appear here.';
  }

  @override
  String get categoryIconFolder => 'Folder';

  @override
  String get categoryIconCode => 'Code';

  @override
  String get categoryIconMobile => 'Mobile';

  @override
  String get categoryIconWeb => 'Web';

  @override
  String get categoryIconDesign => 'Design';

  @override
  String get categoryIconTerminal => 'Terminal';

  @override
  String get categoryIconDatabase => 'Database';

  @override
  String get categoryIconCloud => 'Cloud';

  @override
  String get categoryIconVersionControl => 'Version control';

  @override
  String get categoryIconData => 'Data';

  @override
  String get categoryIconMath => 'Math';

  @override
  String get categoryIconAi => 'AI';

  @override
  String get categoryIconLanguages => 'Languages';

  @override
  String get categoryIconReading => 'Reading';

  @override
  String get categoryIconCourse => 'Course';

  @override
  String get categoryIconScience => 'Science';

  @override
  String get categoryIconIdeas => 'Ideas';

  @override
  String get categoryIconProjects => 'Projects';

  @override
  String get categoryIconDebugging => 'Debugging';

  @override
  String get categoryIconSecurity => 'Security';

  @override
  String get categoryIconAnalytics => 'Analytics';

  @override
  String get categoryIconMusic => 'Music';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorRed => 'Red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorSlate => 'Slate';

  @override
  String get sampleDataLoad => 'Load sample data';

  @override
  String get sampleDataLoaded => 'Sample data added';

  @override
  String get sampleDataRemove => 'Remove sample data';

  @override
  String get sampleDataRemoved => 'Sample data removed';

  @override
  String get sampleDataError =>
      'Couldn\'t update sample data. Please try again.';

  @override
  String get sampleDataBannerTitle => 'You\'re exploring sample data';

  @override
  String get sampleDataBannerMessage =>
      'Sample categories show how Learning OS works. Remove them whenever you\'re ready.';

  @override
  String get sampleDataRemoveTitle => 'Remove sample data?';

  @override
  String get sampleDataRemoveMessage =>
      'All sample categories will be deleted. Categories you created yourself are not affected.';

  @override
  String get sampleFlutterDescription =>
      'Cross-platform apps with widgets, layouts and state management.';

  @override
  String get sampleDartDescription =>
      'The language behind Flutter: types, async code and null safety.';

  @override
  String get sampleUiUxDescription =>
      'Interface design, usability and building design systems.';

  @override
  String get sampleGitDescription =>
      'Version control, branching and collaborating on GitHub.';
}
