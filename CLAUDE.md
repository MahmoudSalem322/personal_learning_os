# Learning OS — working notes

Offline-first Flutter Web app built in phases. See README.md for architecture.
Only implement the phase the user asks for; never jump ahead.

## Phase status

- [x] PHASE 01 — Architecture & Foundation
- [x] PHASE 02 — Categories
- [ ] PHASE 03 — Resources
- [ ] PHASE 04 — Notes
- [ ] PHASE 05 — Tasks
- [ ] PHASE 06 — Dashboard & Global Search
- [ ] PHASE 07 — Notifications & Reminders
- [ ] PHASE 08 — Backup / Import / Export
- [ ] PHASE 09 — Polish / Performance / Accessibility / Production

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
- Sample data ids start with `sample-` (`SampleDataService.idPrefix`); later
  phases extend `SampleDataService.load/remove` for their own stores.
- Deleting a category currently removes only the category. When resources,
  notes and tasks arrive, decide how their `categoryId` is handled on delete.
- Before finishing a phase: `flutter analyze` clean, `flutter test` green,
  `flutter build web` succeeds.
