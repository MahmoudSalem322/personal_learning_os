import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/routing/app_transition_page.dart';
import 'pages/categories_page.dart';
import 'pages/category_detail_page.dart';

/// `/categories` and `/categories/:id`.
GoRoute categoriesRoute() => GoRoute(
  path: AppRoutes.categories,
  name: 'categories',
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: const CategoriesPage()),
  routes: [
    GoRoute(
      path: ':${AppRoutes.idParam}',
      name: 'category',
      pageBuilder: (context, state) => AppTransitionPage(
        key: state.pageKey,
        child: CategoryDetailPage(
          categoryId: state.pathParameters[AppRoutes.idParam]!,
        ),
      ),
    ),
  ],
);
