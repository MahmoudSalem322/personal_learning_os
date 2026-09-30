import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/routing/app_transition_page.dart';
import 'pages/task_detail_page.dart';
import 'pages/tasks_page.dart';

/// `/tasks` and `/tasks/:id`.
GoRoute tasksRoute() => GoRoute(
  path: AppRoutes.tasks,
  name: 'tasks',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const TasksPage()),
  routes: [
    GoRoute(
      path: ':${AppRoutes.idParam}',
      name: 'task',
      pageBuilder: (context, state) => AppTransitionPage(
        key: state.pageKey,
        child: TaskDetailPage(taskId: state.pathParameters[AppRoutes.idParam]!),
      ),
    ),
  ],
);
