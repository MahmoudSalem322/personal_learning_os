# Learning OS — working notes

Offline-first Flutter Web app built in phases. See README.md for architecture.
Only implement the phase the user asks for; never jump ahead.

## Phase status

- [x] PHASE 01 — Architecture & Foundation
- [x] PHASE 02 — Categories
- [x] PHASE 03 — Resources
- [x] PHASE 04 — Notes
- [x] PHASE 05 — Tasks
- [x] PHASE 06 — Dashboard & Global Search
- [x] PHASE 07 — Notifications & Reminders
- [x] PHASE 08 — Backup / Import / Export
- [x] PHASE 09 — Polish / Performance / Accessibility / Production

## Conventions

- Material comes from `package:material_ui/material_ui.dart`, NOT
  `package:flutter/material.dart` (decoupled since Flutter 3.44; mixing them
  breaks Theme/Localizations lookups). Localization delegates come from
  material_ui's `GlobalMaterialLocalizations.delegates`, not the generated
  `AppLocalizations.localizationsDelegates`.
- Riverpod 3 without code generation. `Override` is imported from
  `package:flutter_riverpod/misc.dart`.
- No hex colors outside `core/theme/app_palette.dart`; no user-facing string
  literals outside `lib/l10n/*.arb` (run `flutter gen-l10n` after editing).
- Use `EdgeInsetsDirectional` / `AlignmentDirectional` so RTL works.
- New persisted collections: add a store to `AppStores`, a repository
  interface in `features/<x>/domain`, a local implementation in
  `features/<x>/data`, and wrap storage errors in `StorageException`.
- A phase adds `features/<x>/presentation/<x>_routes.dart` and plugs it into
  `_routeFor` in `app/navigation/app_router.dart`; path constants go in
  `core/routing/app_routes.dart`. Detail routes use `AppTransitionPage`.
- `package:flutter/foundation.dart` also exports a `Category` annotation.
  Domain files import it with `show immutable` to avoid clashing with the
  `Category` model.
- Layering per feature: widgets → `<X>Actions` (dialogs, toasts, undo) →
  `<X>Service` (validation, ids, timestamps) → `<X>Repository` interface →
  `Local<X>Repository` (sembast). Widgets never call repositories to write.
- Local repositories delegate to `LocalDocumentStore<T>`
  (`core/storage/local_document_store.dart`): watch/get/save/delete plus
  `clearField`/`setField` for unlinking and re-linking.
- Sample data ids start with `sample-` (`SampleDataService.idPrefix`); later
  phases extend `SampleDataService.load/remove` for their own stores.
- Deleting a category keeps its items and makes them uncategorized (user's
  decision, option B). Each feature that references categories implements
  `CategoryLinks` (see `ResourceCategoryLinks`) and is added to
  `categoryServiceProvider`'s `links`; Undo re-links the same items. Notes
  and tasks must do the same.
- Deleting a resource keeps its notes and tasks and unlinks them:
  implement `ResourceLinks` (see `NoteResourceLinks`, `TaskResourceLinks`)
  and add it to `resourceServiceProvider`'s `links`; `DeletedResource`
  carries the Undo.
- Tasks: due dates are calendar days stored as `yyyy-MM-dd` (local midnight
  in memory) so they never shift across time zones. `TaskService` owns
  `completedAt` (set on completion, kept while completed, cleared on
  reopen). Lists put completed tasks after open ones. Views (All / Today /
  Upcoming / Overdue / Completed) live in `TaskFilter`.
- Notes: Markdown via `package:markdown` (GFM). The editor autosaves with a
  600 ms debounce, flushes on dispose and discards blank new notes. Widget
  tests that open the editor must end with `leaveEditor`/`unmountApp`
  (see `test/features/notes/notes_page_test.dart`) or sembast leaves
  pending timers.
- Category progress rule: rounded mean of its resources' progress
  (`LearningProgress`); no resources means no percentage (not 0%).
- Tags: `TagRules` (normalize/parse) in `features/tags`, shared by resources,
  notes and tasks. Stored lowercase without `#`.
- Opening links: `UrlOpener` (`urlOpenerProvider`) must be called
  synchronously inside the click handler (pop-up blockers). Tests override
  it with `FakeUrlOpener` (see `test/helpers/test_app.dart`).
- Storage helpers: `guardStorage`, `storageErrors`, `tryParseRecord` in
  `core/storage/storage_guard.dart`. Forms use `AppFormDialog`; list filters
  use `FilterMenuButton`.
- Widget tests: use `tester.io(...)` / `tapAndSettleIo` for anything that
  touches sembast, and `findTooltip` for material_ui tooltips.
- Avoid `Container(alignment: ...)` inside `Wrap`/`Row` children: it expands
  to the full available width.
- Global search (`features/search`): `SearchIndex` is pure and ranks
  exact > prefix > word > contains > all words > body; a leading `#`
  searches tags. The index provider is autoDispose (alive only while the
  dialog is open). Ctrl/⌘+K is handled by `GlobalSearchShortcut` in the
  shell; `web/index.html` blocks the browser's own Ctrl+K. New searchable
  kinds add an entry list to `SearchIndex` and a `SearchHit` subclass.
- Filter bars keep their search field in sync with the filter provider
  (search's "Show all" sets the query from outside the page).
- Dashboard (`features/dashboard`): pure `DashboardStats` /
  `DashboardSelectors` feed small providers; overall progress uses the
  category rule over all resources. `AppPage` actions wrap on narrow
  screens; `AppPage.documentTitle` overrides the browser tab title.
- Notifications (`features/notifications`, model `AppNotification` to avoid
  Flutter's `Notification`): the pure `NotificationEngine.run(now)` creates
  them from reminders and task due dates, deduplicated by `key` (dismissed
  ones are soft-deleted and purged after 60 days). Text is built at render
  time from the type, so it follows the language. `NotificationScheduler`
  runs the engine in the app (start, every minute, after changes); widget
  tests disable it (`pumpLearningOs(notificationScheduling: false)` is the
  default) and call the engine through `tester.io`. New delivery methods
  (e.g. Web Notifications) implement `NotificationChannel`.
- Reminders (`features/reminders`) target a task, a resource or a learning
  session. Missed occurrences fire once when the app reopens; reminders
  whose item was deleted wait (Undo brings it back). Preferences live in
  `AppSettings.notifications`.
- Backups (`features/backup`): `BackupSnapshot` holds every store;
  `BackupCodec` (format 1) validates the whole file before anything is
  written; `LocalBackupStore.replaceAll` writes in one transaction. A new
  store must be added to `BackupSnapshot`, `BackupCodec` and
  `LocalBackupStore` (a test counts `AppStores.all`). Import merges (newer
  `updatedAt` wins) or replaces; replace/clear return the previous state
  for Undo. Links to missing items are cleared on import.
- Files: `FileService` (`fileServiceProvider`) downloads and picks files;
  tests override it with `FakeFileService` (`test/helpers/test_app.dart`).
  Settings restored from a backup are pushed to the UI with
  `SettingsController.adopt`.
- Platforms: web and Android. Platform code lives behind interfaces with
  conditional imports (`stub` / `web` via `dart.library.js_interop` / `io`
  via `dart.library.io`): storage factory + path, `UrlOpener`,
  `FileService`, `SystemNotifier`. Tests never hit the io versions (they
  pass an in-memory factory and fakes).
- Notes can link to a task (`Note.taskId`); deleting a task keeps its notes
  unlinked via `TaskItemLinks` / `NoteTaskLinks`, Undo re-links them.
- Keyboard: Ctrl/⌘+K search, N (or Ctrl/⌘+N outside the browser) creates
  the current section's item (`NewItemShortcut`), Esc closes dialogs.
- Accessibility and scale are tested: `test/app/accessibility_test.dart`
  (labels, WCAG AA contrast, 24×24 targets on every page, light/dark) and
  `test/app/performance_test.dart` (1000 items per kind). Add new pages to
  the accessibility list; status colors in `AppPalette` are tuned for 4.5:1.
- Web offline: `web/sw.js` (network-first app files, cache-first CDN
  engine/fonts). Build with `--no-web-resources-cdn` for production.
- Android APK: `flutter build apk --release --target-platform
  android-arm64` (this machine's Application Control policy blocks the
  32-bit ARM `gen_snapshot`). Signed with the debug key.
- Before finishing a phase: `flutter analyze` clean, `flutter test` green,
  `flutter build web` succeeds (and the APK for Android changes).
