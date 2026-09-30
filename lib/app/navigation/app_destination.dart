import 'package:material_ui/material_ui.dart';

import '../../core/routing/app_routes.dart';
import '../../l10n/app_localizations.dart';

/// Top-level sections of the app, in navigation order.
///
/// Each destination is one branch of the shell route, so its declaration
/// order is also its branch index.
enum AppDestination {
  dashboard(
    AppRoutes.dashboard,
    Icons.space_dashboard_outlined,
    Icons.space_dashboard_rounded,
  ),
  notifications(
    AppRoutes.notifications,
    Icons.notifications_none_rounded,
    Icons.notifications_rounded,
  ),
  categories(
    AppRoutes.categories,
    Icons.category_outlined,
    Icons.category_rounded,
  ),
  resources(
    AppRoutes.resources,
    Icons.collections_bookmark_outlined,
    Icons.collections_bookmark_rounded,
  ),
  notes(
    AppRoutes.notes,
    Icons.sticky_note_2_outlined,
    Icons.sticky_note_2_rounded,
  ),
  tasks(
    AppRoutes.tasks,
    Icons.check_circle_outline_rounded,
    Icons.check_circle_rounded,
  ),
  favorites(
    AppRoutes.favorites,
    Icons.star_outline_rounded,
    Icons.star_rounded,
  ),
  settings(AppRoutes.settings, Icons.settings_outlined, Icons.settings_rounded);

  const AppDestination(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  /// Destinations listed in the main navigation; [settings] lives in the
  /// sidebar footer.
  static final List<AppDestination> main = values
      .where((d) => d != AppDestination.settings)
      .toList(growable: false);

  String label(AppLocalizations l10n) => switch (this) {
    AppDestination.dashboard => l10n.navDashboard,
    AppDestination.notifications => l10n.navNotifications,
    AppDestination.categories => l10n.navCategories,
    AppDestination.resources => l10n.navResources,
    AppDestination.notes => l10n.navNotes,
    AppDestination.tasks => l10n.navTasks,
    AppDestination.favorites => l10n.navFavorites,
    AppDestination.settings => l10n.navSettings,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    AppDestination.dashboard => l10n.dashboardSubtitle,
    AppDestination.notifications => l10n.notificationsSubtitle,
    AppDestination.categories => l10n.categoriesSubtitle,
    AppDestination.resources => l10n.resourcesSubtitle,
    AppDestination.notes => l10n.notesSubtitle,
    AppDestination.tasks => l10n.tasksSubtitle,
    AppDestination.favorites => l10n.favoritesSubtitle,
    AppDestination.settings => l10n.settingsSubtitle,
  };
}
