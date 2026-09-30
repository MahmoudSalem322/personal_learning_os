<img src="branding/qabas-icon-1024.png" width="96" alt="Qabas logo">

# Qabas · قبس

*Qabas* (قَبَس) means a spark of light: every lesson, note and task you keep
here is one. A personal, offline-first workspace for organizing learning
resources, notes, tasks and progress. Built with Flutter (web and Android),
Material 3, Riverpod and go_router.

All data stays on the device: IndexedDB in the browser, a private file on
Android. No backend, no account. Backups are plain JSON files you export
and import yourself (Settings → Data).

## Features

- **Categories** with their own colors, icon and computed progress.
- **Resources** (courses, videos, docs, books, …) with type, tags, progress,
  favorites and one-click open.
- **Notes** in Markdown with autosave, preview, checklists and code blocks,
  linked to a category, a resource and/or a task.
- **Tasks** with priority, status, due dates and Today / Upcoming / Overdue /
  Completed views.
- **Dashboard** with totals, continue learning, today's tasks and progress.
- **Global search** (Ctrl/⌘ + K) over everything; `#tag` searches tags.
- **Notifications & reminders**: in-app inbox, due-date alerts, reminders on
  tasks, resources or learning sessions; optional browser notifications.
- **Favorites**, **backup / import / restore**, **English & Arabic (RTL)**,
  light / dark / system themes, keyboard shortcuts.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Build

### Web

```bash
flutter build web --release --no-web-resources-cdn
```

`--no-web-resources-cdn` bundles the Flutter engine (CanvasKit) with the app
instead of loading it from Google's CDN, so the app starts offline even on a
first visit after the files are cached. The service worker (`web/sw.js`)
caches the app on the first visit; after that it opens without a network.

Host `build/web` on any static server. Rewrite unknown paths to `index.html`
(SPA fallback), otherwise refreshing on an inner route such as `/notes/123`
returns 404. Examples: Firebase Hosting `"rewrites": [{"source": "**",
"destination": "/index.html"}]`; Netlify `/* /index.html 200` in
`_redirects`; nginx `try_files $uri /index.html;`.

### Android APK

```bash
flutter build apk --release --target-platform android-arm64
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. It is
signed with the debug key (fine for installing directly). Before publishing
to Google Play, create an upload keystore and a release `signingConfig` in
`android/app/build.gradle.kts`.

`android-arm64` covers practically every phone sold since 2017. Drop the flag
to also build 32-bit ARM and x86_64 (larger APK).

## Brand & icons

The logo is one white spark on navy, drawn in code by `QabasMarkPainter`
(`lib/core/widgets/app_logo.dart`); the in-app logo and every icon come from
it. After changing it, regenerate the web icons, favicon, Android launcher
icons (legacy, adaptive and themed) and `branding/qabas-icon-1024.png`:

```bash
flutter test tool/generate_icons_test.dart
```

## Quality gates

```bash
flutter analyze
flutter test
```

The suite includes accessibility checks (labels, WCAG AA contrast, 24×24
targets) on every page in light and dark mode, and performance checks with
1000 resources, notes and tasks.

## Architecture

```text
lib/
├── main.dart                 Entry point: error handlers, URL strategy, bootstrap
├── app/                      Composition root (knows about every feature)
│   ├── app.dart              MaterialApp.router, theme + locale wiring
│   ├── bootstrap.dart        Opens storage, loads settings before first frame
│   ├── error_handling.dart   Logs uncaught errors; calm fallback widget
│   ├── navigation/           GoRouter, destinations, 404 page
│   └── shell/                Responsive shell, sidebar, keyboard shortcuts
├── core/                     Feature-agnostic building blocks
│   ├── services/             UrlOpener, FileService, SystemNotifier (web/native)
│   ├── storage/              sembast database, stores, migrations, providers
│   ├── theme/                Design system tokens + ThemeData
│   └── widgets/              AppPage, AppCard, AppStateView, AppSkeleton, AppToast
├── features/<feature>/
│   ├── domain/               Models, repository interfaces, services (pure Dart)
│   ├── data/                 Repository implementations (local storage)
│   └── presentation/         Providers, actions, pages, widgets
└── l10n/                     ARB files (en, ar) + generated localizations
```

Features: `categories`, `resources`, `notes`, `tasks`, `tags`, `dashboard`,
`search`, `notifications`, `reminders`, `favorites`, `backup`, `settings`,
`sample_data`.

Data flow: `Widget → Actions → Service → Repository interface → Local store`.
Widgets never write to the database; swapping local storage for a backend
means adding repository implementations and changing providers.

Dependency direction: `app → features → core`. `core` never imports a
feature.

### Platforms

Platform-specific code sits behind small interfaces in `core/services` and
`core/storage`, picked with conditional imports:

| | Web | Android | Tests (Dart VM) |
|---|---|---|---|
| Storage | sembast on IndexedDB | sembast file in app documents | in-memory |
| Open links | new browser tab | `url_launcher` | fake |
| Backup files | download / file input | `file_picker` save/open dialogs | fake |
| System notifications | Notification API (opt-in) | in-app only | fake |

### Design system

| Token | Where | Use |
|---|---|---|
| Colors | `core/theme/app_colors.dart` | `context.colors.primary`, `.mutedText`, `.border`, ... |
| Typography | `core/theme/app_typography.dart` | `context.textStyles.heading`, `.title`, `.body`, `.caption`, `.label` |
| Spacing | `core/theme/app_spacing.dart` | `AppSpacing.md`, `Gap.lg` (4 · 8 · 12 · 16 · 24 · 32 · 48 · 64) |
| Radius | `core/theme/app_radius.dart` | `AppRadius.card`, `.button`, `.input`, `.dialog`, `.chip` |
| Shadows | `core/theme/app_shadows.dart` | `context.shadows.sm / md / lg` |
| Motion | `core/theme/app_motion.dart` | `AppMotion.fast / normal / slow` |

Hex colors live only in `app_palette.dart` (status colors are tuned for WCAG
AA contrast). User-facing strings live only in `lib/l10n/*.arb`.

### Storage

Stores are declared in `AppStores`; schema changes bump
`AppDatabase.schemaVersion` and add a migration step. If persistent storage
is unavailable, the app falls back to memory and shows a warning. Backups
cover every store (a test fails if a new store is left out).
