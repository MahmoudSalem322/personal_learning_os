import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import 'pages/favorites_page.dart';

/// `/favorites`.
GoRoute favoritesRoute() => GoRoute(
  path: AppRoutes.favorites,
  name: 'favorites',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const FavoritesPage()),
);
