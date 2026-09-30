import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../features/categories/presentation/categories_routes.dart';
import '../../features/dashboard/presentation/dashboard_routes.dart';
import '../../features/notes/presentation/notes_routes.dart';
import '../../features/notifications/presentation/notifications_routes.dart';
import '../../features/resources/presentation/resources_routes.dart';
import '../../features/settings/presentation/settings_routes.dart';
import '../../features/tasks/presentation/tasks_routes.dart';
import '../shell/app_shell.dart';
import 'app_destination.dart';
import 'not_found_page.dart';
import 'placeholder_page.dart';

/// The app router. Created once per [ProviderScope] and never rebuilt on
/// settings changes, so navigation state survives theme/language switches.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) =>
        state.uri.path == AppRoutes.root ? AppRoutes.dashboard : null,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          for (final destination in AppDestination.values)
            StatefulShellBranch(routes: [_routeFor(destination)]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Root route (with nested detail routes) of each section. Each phase
/// replaces its destination's placeholder with the feature's routes.
GoRoute _routeFor(AppDestination destination) => switch (destination) {
  AppDestination.dashboard => dashboardRoute(),
  AppDestination.notifications => notificationsRoute(),
  AppDestination.categories => categoriesRoute(),
  AppDestination.resources => resourcesRoute(),
  AppDestination.notes => notesRoute(),
  AppDestination.tasks => tasksRoute(),
  AppDestination.settings => settingsRoute(),
  AppDestination.favorites => GoRoute(
    path: destination.path,
    name: destination.name,
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: PlaceholderPage(destination: destination),
    ),
  ),
};
