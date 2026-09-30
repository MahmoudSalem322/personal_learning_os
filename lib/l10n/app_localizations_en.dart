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
      'The sample categories, resources and notes show how Learning OS works. Remove them whenever you\'re ready.';

  @override
  String get sampleDataRemoveTitle => 'Remove sample data?';

  @override
  String get sampleDataRemoveMessage =>
      'All sample categories, resources and notes will be deleted. What you created yourself is kept.';

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

  @override
  String get sampleResourceFlutterDocs =>
      'Official guides, cookbook recipes and API reference for Flutter.';

  @override
  String get sampleResourceRiverpod =>
      'Reactive caching and state management for Flutter and Dart.';

  @override
  String get sampleResourceFlutterYoutube =>
      'Talks, Widget of the Week and release updates from the Flutter team.';

  @override
  String get sampleResourceFlutterRepo =>
      'Source code, issues and roadmap of the Flutter framework.';

  @override
  String get sampleResourceDartLanguage =>
      'A tour of Dart\'s syntax, types, classes and async features.';

  @override
  String get sampleResourceEffectiveDart =>
      'Guidelines for writing consistent, readable and idiomatic Dart.';

  @override
  String get sampleResourceMaterial =>
      'Google\'s design system: components, color, type and motion.';

  @override
  String get sampleResourceProGit =>
      'The free book on Git: basics, branching, workflows and internals.';

  @override
  String get resourceTypeWebsite => 'Website';

  @override
  String get resourceTypeYoutube => 'YouTube';

  @override
  String get resourceTypeCourse => 'Course';

  @override
  String get resourceTypeBook => 'Book';

  @override
  String get resourceTypePdf => 'PDF';

  @override
  String get resourceTypeArticle => 'Article';

  @override
  String get resourceTypeGithub => 'GitHub';

  @override
  String get resourceTypeDocumentation => 'Documentation';

  @override
  String get resourceTypeOther => 'Other';

  @override
  String get resourcesNew => 'Add resource';

  @override
  String resourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
      zero: 'No resources',
    );
    return '$_temp0';
  }

  @override
  String get resourcesSearchHint => 'Search title, link or #tag';

  @override
  String get resourcesEmptyTitle => 'Your learning library is empty';

  @override
  String get resourcesEmptyMessage =>
      'Start building your knowledge base by adding your first resource.';

  @override
  String get resourcesNoResultsTitle => 'No matching resources';

  @override
  String get resourcesNoResultsMessage =>
      'Try a different search or clear the filters.';

  @override
  String get resourcesClearFilters => 'Clear filters';

  @override
  String get filterAll => 'All';

  @override
  String get filterType => 'Type';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterProgress => 'Progress';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterUncategorized => 'Uncategorized';

  @override
  String get progressNotStarted => 'Not started';

  @override
  String get progressInProgress => 'In progress';

  @override
  String get progressCompleted => 'Completed';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortRecentlyAdded => 'Recently added';

  @override
  String get sortRecentlyOpened => 'Recently opened';

  @override
  String get sortTitle => 'Title (A–Z)';

  @override
  String get sortProgress => 'Progress';

  @override
  String get resourceFormCreateTitle => 'Add resource';

  @override
  String get resourceFormEditTitle => 'Edit resource';

  @override
  String get resourceFormUrl => 'Link';

  @override
  String get resourceFormUrlHint => 'https://…';

  @override
  String get resourceFormTitle => 'Title';

  @override
  String get resourceFormTitleHint => 'Leave empty to use the site name';

  @override
  String get resourceFormDescription => 'Description';

  @override
  String get resourceFormDescriptionHint => 'What is it, and why is it useful?';

  @override
  String get resourceFormType => 'Type';

  @override
  String get resourceFormCategory => 'Category';

  @override
  String get resourceFormNoCategory => 'No category';

  @override
  String get resourceFormTags => 'Tags';

  @override
  String get resourceFormTagsHint => 'Type a tag and press Enter';

  @override
  String resourceFormRemoveTag(String tag) {
    return 'Remove tag $tag';
  }

  @override
  String get resourceFormProgress => 'Progress';

  @override
  String get resourceFormFavorite => 'Add to favorites';

  @override
  String get resourceFormCreate => 'Add resource';

  @override
  String get resourceTitleRequired => 'Enter a title or a link';

  @override
  String get resourceUrlInvalid =>
      'Enter a valid web address, like https://example.com';

  @override
  String resourceTooManyTags(int max) {
    return 'Use up to $max tags';
  }

  @override
  String get resourceCreated => 'Resource added';

  @override
  String get resourceUpdated => 'Resource updated';

  @override
  String get resourceDeleted => 'Resource deleted';

  @override
  String get resourceSaveError =>
      'Couldn\'t save the resource. Please try again.';

  @override
  String get resourceDeleteError =>
      'Couldn\'t delete the resource. Please try again.';

  @override
  String resourceDeleteTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get resourceDeleteMessage =>
      'This resource will be removed. You can undo this right after.';

  @override
  String get resourceOpen => 'Open';

  @override
  String get resourceOpenLink => 'Open link in a new tab';

  @override
  String get resourceOpenBlocked =>
      'The browser blocked the new tab. Allow pop-ups for this site and try again.';

  @override
  String get resourceNoLink => 'No link';

  @override
  String get resourceFavoriteAdd => 'Add to favorites';

  @override
  String get resourceFavoriteRemove => 'Remove from favorites';

  @override
  String get resourceUpdateError =>
      'Couldn\'t update the resource. Please try again.';

  @override
  String progressPercent(int value) {
    return '$value%';
  }

  @override
  String progressComplete(int value) {
    return '$value% complete';
  }

  @override
  String resourceLastOpened(String date) {
    return 'Last opened $date';
  }

  @override
  String get resourceNeverOpened => 'Not opened yet';

  @override
  String get resourceNoDescription => 'No description';

  @override
  String get resourceNotFoundTitle => 'Resource not found';

  @override
  String get resourceNotFoundMessage =>
      'It may have been deleted, or the link is incorrect.';

  @override
  String get resourceBackToList => 'All resources';

  @override
  String get resourceDetails => 'Details';

  @override
  String get resourceAbout => 'About';

  @override
  String get detailCreated => 'Created';

  @override
  String get detailUpdated => 'Updated';

  @override
  String get detailLastOpened => 'Last opened';

  @override
  String resourceMoreTags(int count) {
    return '+$count';
  }

  @override
  String categoryResourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
      zero: 'No resources yet',
    );
    return '$_temp0';
  }

  @override
  String categoryDeleteKeepsResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Its $count resources will stay in your library without a category.',
      one: 'Its resource will stay in your library without a category.',
    );
    return '$_temp0';
  }

  @override
  String get categoryStatResources => 'Resources';

  @override
  String get categoryStatCompleted => 'Completed';

  @override
  String get categoryStatProgress => 'Progress';

  @override
  String get categoryResourcesSection => 'Resources';

  @override
  String categoryNoResourcesTitle(String name) {
    return 'No resources in $name yet';
  }

  @override
  String get categoryNoResourcesMessage =>
      'Add the courses, videos, docs or articles you use to learn it.';

  @override
  String get notesNew => 'New note';

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes',
    );
    return '$_temp0';
  }

  @override
  String get notesSearchHint => 'Search notes or #tag';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyMessage =>
      'Capture ideas, summaries and code snippets as you learn. Notes support Markdown.';

  @override
  String get notesNoResultsTitle => 'No matching notes';

  @override
  String get notesNoResultsMessage =>
      'Try a different search or clear the filters.';

  @override
  String get notesSection => 'Notes';

  @override
  String get notesNoneForResource => 'No notes for this resource yet';

  @override
  String notesNoneForCategory(String name) {
    return 'No notes in $name yet';
  }

  @override
  String get notesNoneMessage => 'Write down what you learn while it\'s fresh.';

  @override
  String get sortRecentlyUpdated => 'Recently updated';

  @override
  String get sortRecentlyCreated => 'Recently created';

  @override
  String get noteUntitled => 'Untitled';

  @override
  String get noteTitleLabel => 'Title';

  @override
  String get noteContentLabel => 'Note content';

  @override
  String get noteContentHint => 'Start writing… Markdown is supported.';

  @override
  String get noteBackToList => 'All notes';

  @override
  String get noteModeWrite => 'Write';

  @override
  String get noteModePreview => 'Preview';

  @override
  String get noteSaving => 'Saving…';

  @override
  String get noteSaved => 'Saved';

  @override
  String get noteSaveFailed => 'Not saved. Retrying on your next change.';

  @override
  String get noteEmptyPreview => 'Nothing to preview yet.';

  @override
  String get noteResource => 'Resource';

  @override
  String get noteNoResource => 'No resource';

  @override
  String noteTasks(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get noteCreateError => 'Couldn\'t create the note. Please try again.';

  @override
  String get noteUpdateError => 'Couldn\'t update the note. Please try again.';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteDeleteError => 'Couldn\'t delete the note. Please try again.';

  @override
  String noteDeleteTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get noteDeleteMessage =>
      'This note will be removed. You can undo this right after.';

  @override
  String get noteNotFoundTitle => 'Note not found';

  @override
  String get noteNotFoundMessage =>
      'It may have been deleted, or the link is incorrect.';

  @override
  String get noteTooLong =>
      'This note is too long to save. Split it into smaller notes.';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterPriority => 'Priority';

  @override
  String get sortDueDate => 'Due date';

  @override
  String get sortPriority => 'Priority';

  @override
  String get mdHeading => 'Heading';

  @override
  String get mdHeading1 => 'Heading 1';

  @override
  String get mdHeading2 => 'Heading 2';

  @override
  String get mdHeading3 => 'Heading 3';

  @override
  String get mdBold => 'Bold (Ctrl+B)';

  @override
  String get mdItalic => 'Italic (Ctrl+I)';

  @override
  String get mdInlineCode => 'Inline code';

  @override
  String get mdBulletList => 'Bulleted list';

  @override
  String get mdNumberedList => 'Numbered list';

  @override
  String get mdChecklist => 'Checklist';

  @override
  String get mdQuote => 'Quote';

  @override
  String get mdCodeBlock => 'Code block';

  @override
  String get mdLink => 'Link';

  @override
  String get mdCopyCode => 'Copy code';

  @override
  String get mdCodeCopied => 'Code copied';

  @override
  String get sampleNoteLayoutTitle => 'Flutter layout cheatsheet';

  @override
  String get sampleNoteLayoutContent =>
      '## Core layout widgets\n\n- **Row** / **Column**: lay children out on one axis\n- **Expanded**: fill the remaining space in a Row or Column\n- **Stack**: overlap children\n\n> Constraints go down. Sizes go up. Parent sets position.\n\n```dart\nRow(\n  children: [\n    const Icon(Icons.star),\n    Expanded(child: Text(title)),\n  ],\n)\n```\n\n## To practice\n\n- [x] Build a profile card with Row and Column\n- [ ] Rebuild it responsively with LayoutBuilder\n- [ ] Read about [box constraints](https://docs.flutter.dev/ui/layout/constraints)';

  @override
  String get sampleNoteRiverpodTitle => 'Riverpod in one page';

  @override
  String get sampleNoteRiverpodContent =>
      '## Providers\n\n1. `Provider` for values that never change\n2. `NotifierProvider` for state with methods\n3. `StreamProvider` for live data, like database queries\n\nUse `ref.watch` in `build`, and `ref.read` inside callbacks.\n\n- [ ] Try `select` to rebuild less often';

  @override
  String get sampleNoteGitTitle => 'Git commands I use daily';

  @override
  String get sampleNoteGitContent =>
      '## Everyday\n\n```bash\ngit status\ngit add -p\ngit commit -m \"message\"\ngit push\n```\n\n## Branches\n\n- `git switch -c feature/x` creates and switches\n- `git rebase main` updates a branch\n\n- [x] Configure my name and email\n- [ ] Learn interactive rebase';
}
