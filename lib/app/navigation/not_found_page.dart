import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/routing/app_routes.dart';
import '../../core/widgets/app_state_view.dart';

/// Shown for unknown URLs (mistyped deep links, removed pages).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Title(
      title: '${l10n.notFoundTitle} · ${l10n.appTitle}',
      color: context.colors.primary,
      child: Scaffold(
        body: AppStateView(
          icon: Icons.explore_off_outlined,
          title: l10n.notFoundTitle,
          message: l10n.notFoundMessage,
          action: FilledButton.icon(
            onPressed: () => context.go(AppRoutes.dashboard),
            icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
            label: Text(l10n.notFoundAction),
          ),
        ),
      ),
    );
  }
}
