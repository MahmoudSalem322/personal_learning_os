import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/routing/app_transition_page.dart';
import 'pages/resource_detail_page.dart';
import 'pages/resources_page.dart';

/// `/resources` and `/resources/:id`.
GoRoute resourcesRoute() => GoRoute(
  path: AppRoutes.resources,
  name: 'resources',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const ResourcesPage()),
  routes: [
    GoRoute(
      path: ':${AppRoutes.idParam}',
      name: 'resource',
      pageBuilder: (context, state) => AppTransitionPage(
        key: state.pageKey,
        child: ResourceDetailPage(
          resourceId: state.pathParameters[AppRoutes.idParam]!,
        ),
      ),
    ),
  ],
);
