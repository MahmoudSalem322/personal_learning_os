import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/screen_size.dart';
import '../../core/widgets/app_logo.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../../features/notifications/presentation/widgets/notification_toaster.dart';
import '../../features/search/presentation/global_search_dialog.dart';
import '../../features/search/presentation/search_launcher.dart';
import '../navigation/app_destination.dart';
import 'app_sidebar.dart';
import 'new_item_shortcut.dart';
import 'storage_warning_banner.dart';

/// Responsive frame around every top-level page.
///
/// - Desktop: full sidebar with labels.
/// - Tablet: collapsed icon sidebar.
/// - Mobile: top bar with a navigation drawer.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  AppDestination get _current =>
      AppDestination.values[navigationShell.currentIndex];

  void _select(AppDestination destination) {
    navigationShell.goBranch(
      destination.index,
      // Tapping the active section again returns to its root page.
      initialLocation: destination.index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    // The branch navigators contain a modal barrier with BlockSemantics,
    // which would hide the sidebar from screen readers unless the content
    // lives in its own semantics container.
    final content = NotificationToaster(
      child: NewItemShortcut(
        destination: _current,
        child: Semantics(
          container: true,
          child: Column(
            children: [
              const StorageWarningBanner(),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );

    if (size.isMobile) {
      return GlobalSearchShortcut(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: AppSizes.mobileTopBarHeight,
            titleSpacing: 0,
            title: Row(
              children: [
                const AppLogo(size: 28),
                Gap.sm,
                Flexible(
                  child: Text(
                    context.l10n.appTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              const NotificationBell(),
              Builder(
                builder: (context) => IconButton(
                  tooltip: context.l10n.searchTooltip(searchShortcutLabel()),
                  onPressed: () => showGlobalSearch(context),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
              Gap.xs,
            ],
          ),
          drawer: Drawer(
            width: AppSizes.drawerWidth,
            child: Builder(
              builder: (drawerContext) => AppSidebar(
                selected: _current,
                expanded: true,
                showSearch: false,
                onSelect: (d) {
                  Navigator.of(drawerContext).pop();
                  _select(d);
                },
              ),
            ),
          ),
          body: content,
        ),
      );
    }

    final expanded = size == ScreenSize.desktop;
    final colors = context.colors;
    return GlobalSearchShortcut(
      child: Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              width: expanded
                  ? AppSizes.sidebarExpandedWidth
                  : AppSizes.sidebarCollapsedWidth,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: colors.border),
                ),
              ),
              child: AppSidebar(
                selected: _current,
                expanded: expanded,
                onSelect: _select,
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
