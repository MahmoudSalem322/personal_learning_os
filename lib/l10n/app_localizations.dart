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
  /// **'The sample categories, resources and notes show how Learning OS works. Remove them whenever you\'re ready.'**
  String get sampleDataBannerMessage;

  /// No description provided for @sampleDataRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove sample data?'**
  String get sampleDataRemoveTitle;

  /// No description provided for @sampleDataRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'All sample categories, resources and notes will be deleted. What you created yourself is kept.'**
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

  /// No description provided for @sampleResourceFlutterDocs.
  ///
  /// In en, this message translates to:
  /// **'Official guides, cookbook recipes and API reference for Flutter.'**
  String get sampleResourceFlutterDocs;

  /// No description provided for @sampleResourceRiverpod.
  ///
  /// In en, this message translates to:
  /// **'Reactive caching and state management for Flutter and Dart.'**
  String get sampleResourceRiverpod;

  /// No description provided for @sampleResourceFlutterYoutube.
  ///
  /// In en, this message translates to:
  /// **'Talks, Widget of the Week and release updates from the Flutter team.'**
  String get sampleResourceFlutterYoutube;

  /// No description provided for @sampleResourceFlutterRepo.
  ///
  /// In en, this message translates to:
  /// **'Source code, issues and roadmap of the Flutter framework.'**
  String get sampleResourceFlutterRepo;

  /// No description provided for @sampleResourceDartLanguage.
  ///
  /// In en, this message translates to:
  /// **'A tour of Dart\'s syntax, types, classes and async features.'**
  String get sampleResourceDartLanguage;

  /// No description provided for @sampleResourceEffectiveDart.
  ///
  /// In en, this message translates to:
  /// **'Guidelines for writing consistent, readable and idiomatic Dart.'**
  String get sampleResourceEffectiveDart;

  /// No description provided for @sampleResourceMaterial.
  ///
  /// In en, this message translates to:
  /// **'Google\'s design system: components, color, type and motion.'**
  String get sampleResourceMaterial;

  /// No description provided for @sampleResourceProGit.
  ///
  /// In en, this message translates to:
  /// **'The free book on Git: basics, branching, workflows and internals.'**
  String get sampleResourceProGit;

  /// No description provided for @resourceTypeWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get resourceTypeWebsite;

  /// No description provided for @resourceTypeYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get resourceTypeYoutube;

  /// No description provided for @resourceTypeCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get resourceTypeCourse;

  /// No description provided for @resourceTypeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get resourceTypeBook;

  /// No description provided for @resourceTypePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get resourceTypePdf;

  /// No description provided for @resourceTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get resourceTypeArticle;

  /// No description provided for @resourceTypeGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get resourceTypeGithub;

  /// No description provided for @resourceTypeDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get resourceTypeDocumentation;

  /// No description provided for @resourceTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get resourceTypeOther;

  /// No description provided for @resourcesNew.
  ///
  /// In en, this message translates to:
  /// **'Add resource'**
  String get resourcesNew;

  /// No description provided for @resourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No resources} =1{1 resource} other{{count} resources}}'**
  String resourcesCount(int count);

  /// No description provided for @resourcesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, link or #tag'**
  String get resourcesSearchHint;

  /// No description provided for @resourcesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning library is empty'**
  String get resourcesEmptyTitle;

  /// No description provided for @resourcesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Start building your knowledge base by adding your first resource.'**
  String get resourcesEmptyMessage;

  /// No description provided for @resourcesNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching resources'**
  String get resourcesNoResultsTitle;

  /// No description provided for @resourcesNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the filters.'**
  String get resourcesNoResultsMessage;

  /// No description provided for @resourcesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get resourcesClearFilters;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get filterProgress;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// No description provided for @filterUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get filterUncategorized;

  /// No description provided for @progressNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get progressNotStarted;

  /// No description provided for @progressInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get progressInProgress;

  /// No description provided for @progressCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get progressCompleted;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecentlyAdded;

  /// No description provided for @sortRecentlyOpened.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get sortRecentlyOpened;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (A–Z)'**
  String get sortTitle;

  /// No description provided for @sortProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get sortProgress;

  /// No description provided for @resourceFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add resource'**
  String get resourceFormCreateTitle;

  /// No description provided for @resourceFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit resource'**
  String get resourceFormEditTitle;

  /// No description provided for @resourceFormUrl.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get resourceFormUrl;

  /// No description provided for @resourceFormUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://…'**
  String get resourceFormUrlHint;

  /// No description provided for @resourceFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get resourceFormTitle;

  /// No description provided for @resourceFormTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the site name'**
  String get resourceFormTitleHint;

  /// No description provided for @resourceFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get resourceFormDescription;

  /// No description provided for @resourceFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is it, and why is it useful?'**
  String get resourceFormDescriptionHint;

  /// No description provided for @resourceFormType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get resourceFormType;

  /// No description provided for @resourceFormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get resourceFormCategory;

  /// No description provided for @resourceFormNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get resourceFormNoCategory;

  /// No description provided for @resourceFormTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get resourceFormTags;

  /// No description provided for @resourceFormTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Type a tag and press Enter'**
  String get resourceFormTagsHint;

  /// No description provided for @resourceFormRemoveTag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag {tag}'**
  String resourceFormRemoveTag(String tag);

  /// No description provided for @resourceFormProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get resourceFormProgress;

  /// No description provided for @resourceFormFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get resourceFormFavorite;

  /// No description provided for @resourceFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Add resource'**
  String get resourceFormCreate;

  /// No description provided for @resourceTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title or a link'**
  String get resourceTitleRequired;

  /// No description provided for @resourceUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid web address, like https://example.com'**
  String get resourceUrlInvalid;

  /// No description provided for @resourceTooManyTags.
  ///
  /// In en, this message translates to:
  /// **'Use up to {max} tags'**
  String resourceTooManyTags(int max);

  /// No description provided for @resourceCreated.
  ///
  /// In en, this message translates to:
  /// **'Resource added'**
  String get resourceCreated;

  /// No description provided for @resourceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Resource updated'**
  String get resourceUpdated;

  /// No description provided for @resourceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Resource deleted'**
  String get resourceDeleted;

  /// No description provided for @resourceSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the resource. Please try again.'**
  String get resourceSaveError;

  /// No description provided for @resourceDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the resource. Please try again.'**
  String get resourceDeleteError;

  /// No description provided for @resourceDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String resourceDeleteTitle(String title);

  /// No description provided for @resourceDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This resource will be removed. You can undo this right after.'**
  String get resourceDeleteMessage;

  /// No description provided for @resourceOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get resourceOpen;

  /// No description provided for @resourceOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link in a new tab'**
  String get resourceOpenLink;

  /// No description provided for @resourceOpenBlocked.
  ///
  /// In en, this message translates to:
  /// **'The browser blocked the new tab. Allow pop-ups for this site and try again.'**
  String get resourceOpenBlocked;

  /// No description provided for @resourceNoLink.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get resourceNoLink;

  /// No description provided for @resourceFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get resourceFavoriteAdd;

  /// No description provided for @resourceFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get resourceFavoriteRemove;

  /// No description provided for @resourceUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the resource. Please try again.'**
  String get resourceUpdateError;

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String progressPercent(int value);

  /// No description provided for @progressComplete.
  ///
  /// In en, this message translates to:
  /// **'{value}% complete'**
  String progressComplete(int value);

  /// No description provided for @resourceLastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened {date}'**
  String resourceLastOpened(String date);

  /// No description provided for @resourceNeverOpened.
  ///
  /// In en, this message translates to:
  /// **'Not opened yet'**
  String get resourceNeverOpened;

  /// No description provided for @resourceNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get resourceNoDescription;

  /// No description provided for @resourceNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get resourceNotFoundTitle;

  /// No description provided for @resourceNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or the link is incorrect.'**
  String get resourceNotFoundMessage;

  /// No description provided for @resourceBackToList.
  ///
  /// In en, this message translates to:
  /// **'All resources'**
  String get resourceBackToList;

  /// No description provided for @resourceDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get resourceDetails;

  /// No description provided for @resourceAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get resourceAbout;

  /// No description provided for @detailCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get detailCreated;

  /// No description provided for @detailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get detailUpdated;

  /// No description provided for @detailLastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened'**
  String get detailLastOpened;

  /// No description provided for @resourceMoreTags.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String resourceMoreTags(int count);

  /// No description provided for @categoryResourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No resources yet} =1{1 resource} other{{count} resources}}'**
  String categoryResourcesCount(int count);

  /// No description provided for @categoryDeleteKeepsResources.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Its resource will stay in your library without a category.} other{Its {count} resources will stay in your library without a category.}}'**
  String categoryDeleteKeepsResources(int count);

  /// No description provided for @categoryStatResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get categoryStatResources;

  /// No description provided for @categoryStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get categoryStatCompleted;

  /// No description provided for @categoryStatProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get categoryStatProgress;

  /// No description provided for @categoryResourcesSection.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get categoryResourcesSection;

  /// No description provided for @categoryNoResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'No resources in {name} yet'**
  String categoryNoResourcesTitle(String name);

  /// No description provided for @categoryNoResourcesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the courses, videos, docs or articles you use to learn it.'**
  String get categoryNoResourcesMessage;

  /// No description provided for @notesNew.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNew;

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes} =1{1 note} other{{count} notes}}'**
  String notesCount(int count);

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes or #tag'**
  String get notesSearchHint;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture ideas, summaries and code snippets as you learn. Notes support Markdown.'**
  String get notesEmptyMessage;

  /// No description provided for @notesNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching notes'**
  String get notesNoResultsTitle;

  /// No description provided for @notesNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the filters.'**
  String get notesNoResultsMessage;

  /// No description provided for @notesSection.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSection;

  /// No description provided for @notesNoneForResource.
  ///
  /// In en, this message translates to:
  /// **'No notes for this resource yet'**
  String get notesNoneForResource;

  /// No description provided for @notesNoneForCategory.
  ///
  /// In en, this message translates to:
  /// **'No notes in {name} yet'**
  String notesNoneForCategory(String name);

  /// No description provided for @notesNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Write down what you learn while it\'s fresh.'**
  String get notesNoneMessage;

  /// No description provided for @sortRecentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortRecentlyUpdated;

  /// No description provided for @sortRecentlyCreated.
  ///
  /// In en, this message translates to:
  /// **'Recently created'**
  String get sortRecentlyCreated;

  /// No description provided for @noteUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get noteUntitled;

  /// No description provided for @noteTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleLabel;

  /// No description provided for @noteContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Note content'**
  String get noteContentLabel;

  /// No description provided for @noteContentHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing… Markdown is supported.'**
  String get noteContentHint;

  /// No description provided for @noteBackToList.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get noteBackToList;

  /// No description provided for @noteModeWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get noteModeWrite;

  /// No description provided for @noteModePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get noteModePreview;

  /// No description provided for @noteSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get noteSaving;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get noteSaved;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved. Retrying on your next change.'**
  String get noteSaveFailed;

  /// No description provided for @noteEmptyPreview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview yet.'**
  String get noteEmptyPreview;

  /// No description provided for @noteResource.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get noteResource;

  /// No description provided for @noteNoResource.
  ///
  /// In en, this message translates to:
  /// **'No resource'**
  String get noteNoResource;

  /// No description provided for @noteTasks.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String noteTasks(int done, int total);

  /// No description provided for @noteCreateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the note. Please try again.'**
  String get noteCreateError;

  /// No description provided for @noteUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the note. Please try again.'**
  String get noteUpdateError;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @noteDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the note. Please try again.'**
  String get noteDeleteError;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String noteDeleteTitle(String title);

  /// No description provided for @noteDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This note will be removed. You can undo this right after.'**
  String get noteDeleteMessage;

  /// No description provided for @noteNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Note not found'**
  String get noteNotFoundTitle;

  /// No description provided for @noteNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or the link is incorrect.'**
  String get noteNotFoundMessage;

  /// No description provided for @noteTooLong.
  ///
  /// In en, this message translates to:
  /// **'This note is too long to save. Split it into smaller notes.'**
  String get noteTooLong;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get filterPriority;

  /// No description provided for @sortDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get sortDueDate;

  /// No description provided for @sortPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get sortPriority;

  /// No description provided for @mdHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get mdHeading;

  /// No description provided for @mdHeading1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get mdHeading1;

  /// No description provided for @mdHeading2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get mdHeading2;

  /// No description provided for @mdHeading3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get mdHeading3;

  /// No description provided for @mdBold.
  ///
  /// In en, this message translates to:
  /// **'Bold (Ctrl+B)'**
  String get mdBold;

  /// No description provided for @mdItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic (Ctrl+I)'**
  String get mdItalic;

  /// No description provided for @mdInlineCode.
  ///
  /// In en, this message translates to:
  /// **'Inline code'**
  String get mdInlineCode;

  /// No description provided for @mdBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get mdBulletList;

  /// No description provided for @mdNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get mdNumberedList;

  /// No description provided for @mdChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get mdChecklist;

  /// No description provided for @mdQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get mdQuote;

  /// No description provided for @mdCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code block'**
  String get mdCodeBlock;

  /// No description provided for @mdLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get mdLink;

  /// No description provided for @mdCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get mdCopyCode;

  /// No description provided for @mdCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get mdCodeCopied;

  /// No description provided for @sampleNoteLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter layout cheatsheet'**
  String get sampleNoteLayoutTitle;

  /// No description provided for @sampleNoteLayoutContent.
  ///
  /// In en, this message translates to:
  /// **'## Core layout widgets\n\n- **Row** / **Column**: lay children out on one axis\n- **Expanded**: fill the remaining space in a Row or Column\n- **Stack**: overlap children\n\n> Constraints go down. Sizes go up. Parent sets position.\n\n```dart\nRow(\n  children: [\n    const Icon(Icons.star),\n    Expanded(child: Text(title)),\n  ],\n)\n```\n\n## To practice\n\n- [x] Build a profile card with Row and Column\n- [ ] Rebuild it responsively with LayoutBuilder\n- [ ] Read about [box constraints](https://docs.flutter.dev/ui/layout/constraints)'**
  String get sampleNoteLayoutContent;

  /// No description provided for @sampleNoteRiverpodTitle.
  ///
  /// In en, this message translates to:
  /// **'Riverpod in one page'**
  String get sampleNoteRiverpodTitle;

  /// No description provided for @sampleNoteRiverpodContent.
  ///
  /// In en, this message translates to:
  /// **'## Providers\n\n1. `Provider` for values that never change\n2. `NotifierProvider` for state with methods\n3. `StreamProvider` for live data, like database queries\n\nUse `ref.watch` in `build`, and `ref.read` inside callbacks.\n\n- [ ] Try `select` to rebuild less often'**
  String get sampleNoteRiverpodContent;

  /// No description provided for @sampleNoteGitTitle.
  ///
  /// In en, this message translates to:
  /// **'Git commands I use daily'**
  String get sampleNoteGitTitle;

  /// No description provided for @sampleNoteGitContent.
  ///
  /// In en, this message translates to:
  /// **'## Everyday\n\n```bash\ngit status\ngit add -p\ngit commit -m \"message\"\ngit push\n```\n\n## Branches\n\n- `git switch -c feature/x` creates and switches\n- `git rebase main` updates a branch\n\n- [x] Configure my name and email\n- [ ] Learn interactive rebase'**
  String get sampleNoteGitContent;
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
