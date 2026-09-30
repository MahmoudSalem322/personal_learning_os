import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import 'pages/dashboard_page.dart';

/// `/dashboard`.
GoRoute dashboardRoute() => GoRoute(
  path: AppRoutes.dashboard,
  name: 'dashboard',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const DashboardPage()),
);
