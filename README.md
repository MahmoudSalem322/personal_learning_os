# Learning OS

A personal, offline-first workspace for organizing learning resources, notes,
tasks and progress. Built with Flutter Web, Material 3, Riverpod and go_router.

All data stays in the browser (IndexedDB). No backend, no account.

## Run

```bash
flutter pub get
flutter run -d chrome
```

Release build:

```bash
flutter build web --release
```

Deep links such as `/notes` work with `flutter run`. When hosting the build on
a static server, rewrite unknown paths to `index.html` (SPA fallback),
otherwise refreshing on an inner route returns 404.

## Quality gates

```bash
flutter analyze
flutter test
```

## Architecture

```text
lib/
├── main.dart                 Entry point: URL strategy, bootstrap, ProviderScope
├── app/                      Composition root (knows about every feature)
│   ├── app.dart              MaterialApp.router, theme + locale wiring
│   ├── bootstrap.dart        Opens storage, loads settings before first frame
│   ├── navigation/           GoRouter, destinations, placeholder & 404 pages
│   └── shell/                Responsive shell: sidebar / rail / drawer
├── core/                     Feature-agnostic building blocks
│   ├── constants/            Layout sizes and breakpoints
│   ├── errors/               AppException hierarchy
│   ├── extensions/           context.colors / textStyles / l10n / screenSize
│   ├── routing/              AppRoutes path constants
│   ├── storage/              sembast database, stores, migrations, providers
│   ├── theme/                Design system tokens + ThemeData
│   ├── utils/                ScreenSize
│   └── widgets/              AppPage, AppCard, AppStateView, AppSkeleton, AppToast
├── features/<feature>/
│   ├── domain/               Models + repository interfaces (no Flutter UI)
│   ├── data/                 Repository implementations (local storage)
│   └── presentation/         Riverpod controllers, pages, widgets
└── l10n/                     ARB files (en, ar) + generated localizations
```

Data flow: `Widget → Riverpod controller → Repository interface → Local storage`.
Widgets never touch the database; swapping local storage for a backend means
adding a new repository implementation and changing one provider.

Dependency direction: `app → features → core`. `core` never imports a feature.

### Design system

| Token | Where | Use |
|---|---|---|
| Colors | `core/theme/app_colors.dart` | `context.colors.primary`, `.mutedText`, `.border`, ... |
| Typography | `core/theme/app_typography.dart` | `context.textStyles.heading`, `.title`, `.body`, `.caption`, `.label` |
| Spacing | `core/theme/app_spacing.dart` | `AppSpacing.md`, `Gap.lg` (4 · 8 · 12 · 16 · 24 · 32 · 48 · 64) |
| Radius | `core/theme/app_radius.dart` | `AppRadius.card`, `.button`, `.input`, `.dialog`, `.chip` |
| Shadows | `core/theme/app_shadows.dart` | `context.shadows.sm / md / lg` |
| Motion | `core/theme/app_motion.dart` | `AppMotion.fast / normal / slow` |

Hex colors live only in `app_palette.dart`. User-facing strings live only in
`lib/l10n/*.arb`.

### Storage

sembast on IndexedDB (`sembast_web`). Stores are declared in `AppStores`;
schema changes bump `AppDatabase.schemaVersion` and add a migration step. If
IndexedDB is unavailable, the app falls back to memory and shows a warning.
