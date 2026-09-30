import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import 'pages/notifications_page.dart';

/// `/notifications`.
GoRoute notificationsRoute() => GoRoute(
  path: AppRoutes.notifications,
  name: 'notifications',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const NotificationsPage()),
);
