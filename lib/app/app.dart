import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/extensions/context_extensions.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_typography.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/settings/presentation/settings_mappers.dart';
import '../l10n/app_localizations.dart';
import 'navigation/app_router.dart';

/// Root widget. Rebuilds only when the theme or language preference
/// changes; the router instance is stable across those rebuilds.
class LearningOsApp extends ConsumerWidget {
  const LearningOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themePreference = ref.watch(
      settingsControllerProvider.select((s) => s.themePreference),
    );
    final language = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themePreference.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 200),
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // Material/Cupertino/Widgets delegates come from material_ui, not
      // flutter_localizations, so they match the widgets we render.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: router,
      builder: (context, child) => _LocaleTypography(child: child!),
    );
  }
}

/// Adjusts the type scale for the resolved locale (e.g. no letter spacing
/// for Arabic).
class _LocaleTypography extends StatelessWidget {
  const _LocaleTypography({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final adapted = AppTypography.forLocale(theme.textTheme, locale);
    if (identical(adapted, theme.textTheme)) return child;
    return Theme(
      data: theme.copyWith(textTheme: adapted),
      child: child,
    );
  }
}
