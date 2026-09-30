import 'package:material_ui/material_ui.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_logo.dart';
import '../../features/search/presentation/search_launcher.dart';
import '../../features/settings/presentation/widgets/language_selector.dart';
import '../../features/settings/presentation/widgets/theme_mode_selector.dart';
import '../navigation/app_destination.dart';
import 'sidebar_item.dart';

/// App navigation: brand, main sections and a footer with preferences.
///
/// [expanded] shows labels (desktop and mobile drawer); collapsed shows an
/// icon rail (tablet).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.selected,
    required this.expanded,
    required this.onSelect,
    super.key,
    this.showSearch = true,
  });

  final AppDestination selected;
  final bool expanded;
  final ValueChanged<AppDestination> onSelect;

  /// Hidden in the mobile drawer, where the top bar has a search button.
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final horizontal = expanded ? AppSpacing.sm : AppSpacing.xs;

    Widget itemFor(AppDestination d) => SidebarItem(
      icon: d.icon,
      selectedIcon: d.selectedIcon,
      label: d.label(l10n),
      selected: d == selected,
      expanded: expanded,
      onTap: () => onSelect(d),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.navMainLabel,
      child: Material(
        color: context.colors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(expanded: expanded),
              if (showSearch)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    AppSpacing.xs,
                    horizontal,
                    AppSpacing.xxs,
                  ),
                  child: SearchLauncher(expanded: expanded),
                ),
              Expanded(
                child: FocusTraversalGroup(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontal,
                      vertical: AppSpacing.xs,
                    ),
                    children: [
                      for (final d in AppDestination.main) ...[
                        itemFor(d),
                        Gap.xxs,
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppSpacing.sm,
                  horizontal,
                  AppSpacing.sm,
                ),
                child: expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.xs,
                        children: [
                          const ThemeModeSelector(),
                          const LanguageSelector(),
                          itemFor(AppDestination.settings),
                        ],
                      )
                    : Column(
                        spacing: AppSpacing.xxs,
                        children: [
                          const ThemeModeMenuButton(),
                          const LanguageSelector(compact: true),
                          itemFor(AppDestination.settings),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    if (!expanded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: AppLogo()),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          const AppLogo(),
          Gap.sm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.appTagline,
                  style: text.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
