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
      'The sample categories, resources, notes and tasks show how Learning OS works. Remove them whenever you\'re ready.';

  @override
  String get sampleDataRemoveTitle => 'Remove sample data?';

  @override
  String get sampleDataRemoveMessage =>
      'All sample categories, resources, notes and tasks will be deleted. What you created yourself is kept.';

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
  String get tasksNew => 'Add task';

  @override
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get tasksSearchHint => 'Search tasks or #tag';

  @override
  String get tasksEmptyTitle => 'Plan your next steps';

  @override
  String get tasksEmptyMessage =>
      'Break your learning into tasks, set priorities and track what\'s done.';

  @override
  String get tasksNoResultsTitle => 'No matching tasks';

  @override
  String get tasksNoResultsMessage =>
      'Try a different search or clear the filters.';

  @override
  String get tasksSection => 'Tasks';

  @override
  String get tasksNoneForResource => 'No tasks for this resource yet';

  @override
  String tasksNoneForCategory(String name) {
    return 'No tasks in $name yet';
  }

  @override
  String get tasksNoneMessage =>
      'Turn what you\'re learning into doable steps.';

  @override
  String get taskViewAll => 'All';

  @override
  String get taskViewToday => 'Today';

  @override
  String get taskViewUpcoming => 'Upcoming';

  @override
  String get taskViewOverdue => 'Overdue';

  @override
  String get taskViewCompleted => 'Completed';

  @override
  String get taskPriorityLow => 'Low';

  @override
  String get taskPriorityMedium => 'Medium';

  @override
  String get taskPriorityHigh => 'High';

  @override
  String get taskStatusTodo => 'To do';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskComplete => 'Mark as completed';

  @override
  String get taskReopen => 'Reopen task';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterPriority => 'Priority';

  @override
  String get sortDueDate => 'Due date';

  @override
  String get sortPriority => 'Priority';

  @override
  String get taskFormCreateTitle => 'Add task';

  @override
  String get taskFormEditTitle => 'Edit task';

  @override
  String get taskFormTitle => 'Title';

  @override
  String get taskFormTitleHint => 'What needs to be done?';

  @override
  String get taskFormDescription => 'Description';

  @override
  String get taskFormDescriptionHint =>
      'Any details, steps or links (optional)';

  @override
  String get taskFormDueDate => 'Due date';

  @override
  String get taskFormNoDueDate => 'No due date';

  @override
  String get taskFormClearDueDate => 'Clear due date';

  @override
  String get taskFormCreate => 'Add task';

  @override
  String get taskTitleRequired => 'Enter a title';

  @override
  String taskTooManyTags(int max) {
    return 'Use up to $max tags';
  }

  @override
  String get taskCreated => 'Task added';

  @override
  String get taskUpdated => 'Task updated';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get taskSaveError => 'Couldn\'t save the task. Please try again.';

  @override
  String get taskDeleteError => 'Couldn\'t delete the task. Please try again.';

  @override
  String taskDeleteTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get taskDeleteMessage =>
      'This task will be removed. You can undo this right after.';

  @override
  String get taskUpdateError => 'Couldn\'t update the task. Please try again.';

  @override
  String get taskNotFoundTitle => 'Task not found';

  @override
  String get taskNotFoundMessage =>
      'It may have been deleted, or the link is incorrect.';

  @override
  String get taskBackToList => 'All tasks';

  @override
  String get taskCompletedOn => 'Completed';

  @override
  String get taskDueToday => 'Due today';

  @override
  String get taskDueOverdue => 'Overdue';

  @override
  String taskDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get sampleTaskRiverpod => 'Learn Riverpod providers';

  @override
  String get sampleTaskDartTour => 'Finish the Dart language tour';

  @override
  String get sampleTaskBuildProject => 'Build a first Flutter project';

  @override
  String get sampleTaskGit => 'Set up Git and GitHub';

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

  @override
  String get searchTitle => 'Search';

  @override
  String get searchButton => 'Search…';

  @override
  String searchTooltip(String shortcut) {
    return 'Search ($shortcut)';
  }

  @override
  String get searchHint =>
      'Search categories, resources, notes, tasks or #tags';

  @override
  String get searchEmptyTitle => 'Search everything';

  @override
  String get searchEmptyMessage =>
      'Find categories, resources, notes and tasks. Start with # to search tags.';

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchNoResultsMessage =>
      'Try another word or check the spelling.';

  @override
  String searchShowAll(int count) {
    return 'Show all $count';
  }

  @override
  String get searchKindTags => 'Tags';

  @override
  String searchTagItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get searchHintNavigate => 'to navigate';

  @override
  String get searchHintOpen => 'to open';

  @override
  String get searchHintClose => 'to close';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardQuickAdd => 'Quick add';

  @override
  String get quickAddCategory => 'Category';

  @override
  String get quickAddResource => 'Resource';

  @override
  String get quickAddNote => 'Note';

  @override
  String get quickAddTask => 'Task';

  @override
  String get dashboardStatResources => 'Resources';

  @override
  String get dashboardStatNotes => 'Notes';

  @override
  String get dashboardStatPendingTasks => 'Pending tasks';

  @override
  String get dashboardStatCompletedTasks => 'Completed tasks';

  @override
  String get dashboardStatCategories => 'Categories';

  @override
  String get dashboardStatProgress => 'Overall progress';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardContinueLearning => 'Continue learning';

  @override
  String get dashboardContinueEmpty =>
      'Resources you\'ve started but not finished show up here.';

  @override
  String get dashboardRecentResources => 'Recent resources';

  @override
  String get dashboardRecentEmpty => 'Resources you add show up here.';

  @override
  String get dashboardTodayTasks => 'Today\'s tasks';

  @override
  String get dashboardTodayEmpty => 'Nothing due today. Enjoy the calm.';

  @override
  String get dashboardProgress => 'Learning progress';

  @override
  String get dashboardProgressEmpty =>
      'Add resources to a category to track its progress.';

  @override
  String get dashboardFavorites => 'Favorites';

  @override
  String get dashboardFavoritesEmpty =>
      'Star resources, notes or tasks to keep them here.';

  @override
  String get dashboardWelcomeTitle => 'Welcome to your Learning OS';

  @override
  String get dashboardWelcomeMessage =>
      'Add a category and a few resources to get started, or load sample data to look around.';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Reminders and alerts about what\'s due.';

  @override
  String get notificationsInbox => 'Inbox';

  @override
  String get notificationsReminders => 'Reminders';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUnread => 'Unread';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsClearTitle => 'Clear all notifications?';

  @override
  String get notificationsClearMessage =>
      'Your inbox will be emptied. You can undo this right after.';

  @override
  String get notificationsCleared => 'Notifications cleared';

  @override
  String get notificationsError =>
      'Couldn\'t update notifications. Please try again.';

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsEmptyMessage =>
      'Reminders and due-date alerts will show up here.';

  @override
  String get notificationsAllReadTitle => 'Nothing unread';

  @override
  String get notificationsAllReadMessage => 'You\'ve read every notification.';

  @override
  String get notificationsOffMessage =>
      'Notifications are turned off. Nothing new will be added.';

  @override
  String get notificationsView => 'View';

  @override
  String notificationsNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new notifications',
      one: '1 new notification',
    );
    return '$_temp0';
  }

  @override
  String notificationsUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count unread',
      one: 'Notifications, 1 unread',
    );
    return '$_temp0';
  }

  @override
  String get notificationUnread => 'Unread';

  @override
  String get notificationMarkRead => 'Mark as read';

  @override
  String get notificationMarkUnread => 'Mark as unread';

  @override
  String get notificationRemove => 'Remove';

  @override
  String get notificationRemoved => 'Notification removed';

  @override
  String get notificationItemMissing => 'This item no longer exists.';

  @override
  String get notificationTaskReminder => 'Task reminder';

  @override
  String get notificationUpcomingTask => 'Due soon';

  @override
  String get notificationOverdueTask => 'Overdue task';

  @override
  String get notificationLearningReminder => 'Time to learn';

  @override
  String get notificationWelcomeTitle => 'Welcome to Learning OS';

  @override
  String get notificationWelcomeMessage =>
      'Reminders and due-date alerts will show up here. Set reminders on tasks, resources or learning sessions.';

  @override
  String notificationDueToday(String title) {
    return '\"$title\" is due today';
  }

  @override
  String notificationDueTomorrow(String title) {
    return '\"$title\" is due tomorrow';
  }

  @override
  String notificationDueOn(String title, String date) {
    return '\"$title\" is due $date';
  }

  @override
  String notificationWasDue(String title, String date) {
    return '\"$title\" was due $date';
  }

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get notificationPrefEnabled => 'Allow notifications';

  @override
  String get notificationPrefEnabledHint =>
      'Turn off to stop all new notifications.';

  @override
  String get notificationPrefReminders => 'Reminders';

  @override
  String get notificationPrefRemindersHint =>
      'Reminders you set on tasks, resources and learning sessions.';

  @override
  String get notificationPrefUpcoming => 'Upcoming tasks';

  @override
  String get notificationPrefUpcomingHint =>
      'Open tasks due today or tomorrow.';

  @override
  String get notificationPrefOverdue => 'Overdue tasks';

  @override
  String get notificationPrefOverdueHint => 'Open tasks past their due date.';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get remindersNew => 'New reminder';

  @override
  String get remindersUpcoming => 'Upcoming';

  @override
  String get remindersPast => 'Past';

  @override
  String get remindersEmptyTitle => 'No reminders yet';

  @override
  String get remindersEmptyMessage =>
      'Schedule a learning session, or set a reminder from any task or resource.';

  @override
  String get remindersNoneForItem => 'No reminders yet.';

  @override
  String get reminderRemindMe => 'Remind me';

  @override
  String get reminderFormTitle => 'New reminder';

  @override
  String get reminderFormEditTitle => 'Edit reminder';

  @override
  String get reminderFormCreate => 'Set reminder';

  @override
  String get reminderLabel => 'What do you want to learn?';

  @override
  String get reminderLabelHint =>
      'e.g. Practice Flutter layouts for 30 minutes';

  @override
  String get reminderLabelRequired => 'Describe the learning session';

  @override
  String get reminderNote => 'Note (optional)';

  @override
  String get reminderNoteHint => 'Anything to remember when it fires';

  @override
  String get reminderWhen => 'When';

  @override
  String get reminderRepeat => 'Repeat';

  @override
  String get reminderRepeatNone => 'Once';

  @override
  String get reminderRepeatDaily => 'Every day';

  @override
  String get reminderRepeatWeekly => 'Every week';

  @override
  String get reminderPresetInAnHour => 'In an hour';

  @override
  String get reminderPresetTonight => 'This evening';

  @override
  String get reminderPresetTomorrow => 'Tomorrow morning';

  @override
  String get reminderTimeInPast => 'Pick a time in the future';

  @override
  String reminderSetFor(String when) {
    return 'Reminder set for $when';
  }

  @override
  String get reminderSaveError =>
      'Couldn\'t save the reminder. Please try again.';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get reminderDeleteError =>
      'Couldn\'t delete the reminder. Please try again.';

  @override
  String get reminderPaused => 'Paused';

  @override
  String get reminderPause => 'Pause reminder';

  @override
  String get reminderResume => 'Resume reminder';

  @override
  String reminderDone(String when) {
    return 'Done $when';
  }

  @override
  String get reminderItemDeleted => 'Deleted item (kept in case you undo)';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String timeTomorrowAt(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String timeYesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String timeDateAt(String date, String time) {
    return '$date at $time';
  }

  @override
  String get settingsAppearance => 'Appearance & language';

  @override
  String get settingsChange => 'Change';

  @override
  String get settingsNotificationsOn => 'On. Choose which alerts you get.';

  @override
  String get settingsNotificationsOff =>
      'Off. Nothing new is added to your inbox.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutMessage =>
      'Your personal learning workspace. Everything stays in this browser on this device: nothing is sent to a server. Export a backup to keep a copy or move to another device.';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupExportHint =>
      'Download everything (categories, resources, notes, tasks, reminders, notifications and settings) as a JSON file.';

  @override
  String get backupExportAction => 'Export';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupImportHint =>
      'Restore from a backup file. You\'ll see what\'s inside and choose to merge or replace before anything changes.';

  @override
  String get backupImportAction => 'Import';

  @override
  String get backupClear => 'Clear all data';

  @override
  String get backupClearHint =>
      'Delete every category, resource, note, task, reminder and notification. Your preferences are kept.';

  @override
  String get backupClearAction => 'Clear data';

  @override
  String get backupVolatileWarning =>
      'This browser isn\'t saving data permanently right now. Export a backup so you don\'t lose your work.';

  @override
  String get backupExported => 'Backup downloaded';

  @override
  String get backupExportError =>
      'Couldn\'t create the backup. Please try again.';

  @override
  String get backupReadError => 'Couldn\'t read the file. Please try again.';

  @override
  String get backupImportError =>
      'Couldn\'t import the backup. Your data wasn\'t changed.';

  @override
  String get backupClearError => 'Couldn\'t clear your data. Please try again.';

  @override
  String get backupImportTitle => 'Import backup';

  @override
  String backupExportedOn(String when) {
    return 'Exported $when';
  }

  @override
  String get backupMerge => 'Merge';

  @override
  String get backupMergeHint =>
      'keep your data, add what\'s new and update items that are newer in the backup.';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupReplaceHint =>
      'delete your current data and settings and use the backup\'s instead.';

  @override
  String get backupReplaceConfirmTitle => 'Replace all your data?';

  @override
  String get backupReplaceConfirmMessage =>
      'Everything you have now will be replaced by the backup. You can undo this right after.';

  @override
  String get backupMerged => 'Backup merged';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupClearConfirmTitle => 'Clear all data?';

  @override
  String get backupClearConfirmMessage =>
      'All categories, resources, notes, tasks, reminders and notifications will be deleted. Consider exporting a backup first. You can undo this right after.';

  @override
  String get backupCleared => 'All data cleared';

  @override
  String get backupInvalidTitle => 'Can\'t import this file';

  @override
  String get backupNothingChanged => 'Nothing was changed.';

  @override
  String get backupErrorTooLarge =>
      'The file is too large to be a Learning OS backup.';

  @override
  String get backupErrorNotJson => 'The file isn\'t valid JSON.';

  @override
  String get backupErrorNotBackup => 'This isn\'t a Learning OS backup file.';

  @override
  String get backupErrorNewer =>
      'This backup was made by a newer version of Learning OS. Update the app and try again.';

  @override
  String backupErrorInvalid(int count, String kind) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in $kind are damaged.',
      one: '1 item in $kind is damaged.',
    );
    return '$_temp0';
  }

  @override
  String backupErrorDuplicates(String kind) {
    return 'The same item appears more than once in $kind.';
  }
}
