import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import 'pages/settings_page.dart';

/// `/settings`.
GoRoute settingsRoute() => GoRoute(
  path: AppRoutes.settings,
  name: 'settings',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const SettingsPage()),
);
