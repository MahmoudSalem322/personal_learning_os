import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routing/app_routes.dart';
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
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: destination.path,
                  name: destination.name,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: _pageFor(destination),
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Root page of each section. Phases replace their placeholder here and add
/// nested routes (e.g. `:id`) to the matching branch.
Widget _pageFor(AppDestination destination) => switch (destination) {
  AppDestination.dashboard ||
  AppDestination.categories ||
  AppDestination.resources ||
  AppDestination.notes ||
  AppDestination.tasks ||
  AppDestination.favorites ||
  AppDestination.settings => PlaceholderPage(destination: destination),
};
