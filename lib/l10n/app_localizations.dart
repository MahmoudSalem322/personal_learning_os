import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Product name shown in the sidebar and browser tab.
  ///
  /// In en, this message translates to:
  /// **'Learning OS'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Personal learning workspace'**
  String get appTagline;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get navResources;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open navigation menu'**
  String get navOpenMenu;

  /// No description provided for @navMainLabel.
  ///
  /// In en, this message translates to:
  /// **'Main navigation'**
  String get navMainLabel;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning at a glance.'**
  String get dashboardSubtitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your learning into focused areas.'**
  String get categoriesSubtitle;

  /// No description provided for @resourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courses, videos, docs and articles in one library.'**
  String get resourcesSubtitle;

  /// No description provided for @notesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture what you learn, in your own words.'**
  String get notesSubtitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and track the next steps of your learning.'**
  String get tasksSubtitle;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you starred, in one place.'**
  String get favoritesSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize how Learning OS looks and works.'**
  String get settingsSubtitle;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'{section} is on its way'**
  String comingSoonTitle(String section);

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This space is part of an upcoming phase. The foundation is ready, and it will appear here soon.'**
  String get comingSoonMessage;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for doesn\'t exist or may have been moved.'**
  String get notFoundMessage;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get notFoundAction;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorGenericMessage;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @storageVolatileWarning.
  ///
  /// In en, this message translates to:
  /// **'Local storage is unavailable in this browser session. Your changes won\'t be kept after you close this tab.'**
  String get storageVolatileWarning;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your preference. Please try again.'**
  String get settingsSaveError;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSave;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get actionMore;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use {max} characters or fewer'**
  String validationTooLong(int max);

  /// No description provided for @dateCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String dateCreatedOn(String date);

  /// No description provided for @dateUpdatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String dateUpdatedOn(String date);

  /// No description provided for @categoriesNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesNew;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No categories} =1{1 category} other{{count} categories}}'**
  String categoriesCount(int count);

  /// No description provided for @categoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter categories'**
  String get categoriesSearchHint;

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your learning'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Categories are the areas you\'re learning, like Flutter, Dart or UI/UX. Create your first one to get started.'**
  String get categoriesEmptyMessage;

  /// No description provided for @categoriesNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching categories'**
  String get categoriesNoResultsTitle;

  /// No description provided for @categoriesNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”. Try a different name.'**
  String categoriesNoResultsMessage(String query);

  /// No description provided for @categoryFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryFormCreateTitle;

  /// No description provided for @categoryFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryFormEditTitle;

  /// No description provided for @categoryFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryFormName;

  /// No description provided for @categoryFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Flutter'**
  String get categoryFormNameHint;

  /// No description provided for @categoryFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryFormDescription;

  /// No description provided for @categoryFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What are you learning in this area?'**
  String get categoryFormDescriptionHint;

  /// No description provided for @categoryFormIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryFormIcon;

  /// No description provided for @categoryFormColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryFormColor;

  /// No description provided for @categoryFormPreviewName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryFormPreviewName;

  /// No description provided for @categoryFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get categoryFormCreate;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get categoryNameTaken;

  /// No description provided for @categoryNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get categoryNoDescription;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categorySaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the category. Please try again.'**
  String get categorySaveError;

  /// No description provided for @categoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the category. Please try again.'**
  String get categoryDeleteError;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String categoryDeleteTitle(String name);

  /// No description provided for @categoryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This category will be removed. You can undo this right after.'**
  String get categoryDeleteMessage;

  /// No description provided for @categoryNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFoundTitle;

  /// No description provided for @categoryNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or the link is incorrect.'**
  String get categoryNotFoundMessage;

  /// No description provided for @categoryBackToList.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get categoryBackToList;

  /// No description provided for @categoryDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get categoryDetailEmptyTitle;

  /// No description provided for @categoryDetailEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Resources, notes and tasks you add to {name} will appear here.'**
  String categoryDetailEmptyMessage(String name);

  /// No description provided for @categoryIconFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get categoryIconFolder;

  /// No description provided for @categoryIconCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get categoryIconCode;

  /// No description provided for @categoryIconMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get categoryIconMobile;

  /// No description provided for @categoryIconWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get categoryIconWeb;

  /// No description provided for @categoryIconDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get categoryIconDesign;

  /// No description provided for @categoryIconTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get categoryIconTerminal;

  /// No description provided for @categoryIconDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get categoryIconDatabase;

  /// No description provided for @categoryIconCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get categoryIconCloud;

  /// No description provided for @categoryIconVersionControl.
  ///
  /// In en, this message translates to:
  /// **'Version control'**
  String get categoryIconVersionControl;

  /// No description provided for @categoryIconData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get categoryIconData;

  /// No description provided for @categoryIconMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get categoryIconMath;

  /// No description provided for @categoryIconAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get categoryIconAi;

  /// No description provided for @categoryIconLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get categoryIconLanguages;

  /// No description provided for @categoryIconReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get categoryIconReading;

  /// No description provided for @categoryIconCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get categoryIconCourse;

  /// No description provided for @categoryIconScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get categoryIconScience;

  /// No description provided for @categoryIconIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get categoryIconIdeas;

  /// No description provided for @categoryIconProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get categoryIconProjects;

  /// No description provided for @categoryIconDebugging.
  ///
  /// In en, this message translates to:
  /// **'Debugging'**
  String get categoryIconDebugging;

  /// No description provided for @categoryIconSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get categoryIconSecurity;

  /// No description provided for @categoryIconAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get categoryIconAnalytics;

  /// No description provided for @categoryIconMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryIconMusic;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorSlate;

  /// No description provided for @sampleDataLoad.
  ///
  /// In en, this message translates to:
  /// **'Load sample data'**
  String get sampleDataLoad;

  /// No description provided for @sampleDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample data added'**
  String get sampleDataLoaded;

  /// No description provided for @sampleDataRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove sample data'**
  String get sampleDataRemove;

  /// No description provided for @sampleDataRemoved.
  ///
  /// In en, this message translates to:
  /// **'Sample data removed'**
  String get sampleDataRemoved;

  /// No description provided for @sampleDataError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update sample data. Please try again.'**
  String get sampleDataError;

  /// No description provided for @sampleDataBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re exploring sample data'**
  String get sampleDataBannerTitle;

  /// No description provided for @sampleDataBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sample categories show how Learning OS works. Remove them whenever you\'re ready.'**
  String get sampleDataBannerMessage;

  /// No description provided for @sampleDataRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove sample data?'**
  String get sampleDataRemoveTitle;

  /// No description provided for @sampleDataRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'All sample categories will be deleted. Categories you created yourself are not affected.'**
  String get sampleDataRemoveMessage;

  /// No description provided for @sampleFlutterDescription.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform apps with widgets, layouts and state management.'**
  String get sampleFlutterDescription;

  /// No description provided for @sampleDartDescription.
  ///
  /// In en, this message translates to:
  /// **'The language behind Flutter: types, async code and null safety.'**
  String get sampleDartDescription;

  /// No description provided for @sampleUiUxDescription.
  ///
  /// In en, this message translates to:
  /// **'Interface design, usability and building design systems.'**
  String get sampleUiUxDescription;

  /// No description provided for @sampleGitDescription.
  ///
  /// In en, this message translates to:
  /// **'Version control, branching and collaborating on GitHub.'**
  String get sampleGitDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
