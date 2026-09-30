import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/app/navigation/not_found_page.dart';
import 'package:personal_learning_os/app/shell/app_sidebar.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../helpers/test_app.dart';

void main() {
  group('responsive shell', () {
    testWidgets('desktop shows the expanded sidebar with labels', (
      tester,
    ) async {
      await tester.pumpLearningOs();

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.text('Resources'), findsOneWidget);
      expect(find.text('Personal learning workspace'), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('tablet shows a collapsed icon sidebar', (tester) async {
      await tester.pumpLearningOs(size: TestViewports.tablet);

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.text('Personal learning workspace'), findsNothing);
      expect(findTooltip('Resources'), findsOneWidget);
    });

    testWidgets('mobile uses a top bar and navigation drawer', (tester) async {
      await tester.pumpLearningOs(size: TestViewports.mobile);

      expect(find.byType(AppSidebar), findsNothing);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.byType(AppSidebar), findsOneWidget);

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.byType(AppSidebar), findsNothing, reason: 'drawer closes');
      expect(find.text('Favorites is on its way'), findsOneWidget);
    });

    testWidgets('no layout overflows at any breakpoint', (tester) async {
      for (final size in [
        TestViewports.desktop,
        TestViewports.tablet,
        TestViewports.mobile,
        const Size(320, 568),
      ]) {
        await tester.pumpLearningOs(size: size);
        expect(tester.takeException(), isNull, reason: 'at $size');
      }
    });
  });

  group('accessibility', () {
    testWidgets('sidebar is exposed to screen readers alongside the page', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpLearningOs();

      expect(find.bySemanticsLabel('Main navigation'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Resources')),
        isSemantics(
          label: 'Resources',
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Dashboard').first),
        isSemantics(isSelected: true, isButton: true, hasSelectedState: true),
      );
      handle.dispose();
    });

    testWidgets('meets tap-target and labeled-control guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpLearningOs();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('routing', () {
    testWidgets('opens on the dashboard', (tester) async {
      final container = await tester.pumpLearningOs();
      final router = container.read(appRouterProvider);

      expect(router.state.uri.path, '/dashboard');
      expect(find.text('Dashboard is on its way'), findsOneWidget);
    });

    testWidgets('sidebar navigation updates the URL', (tester) async {
      final container = await tester.pumpLearningOs();
      final router = container.read(appRouterProvider);

      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/tasks');
      expect(find.text('Tasks is on its way'), findsOneWidget);
    });

    testWidgets('deep links open the matching section', (tester) async {
      final container = await tester.pumpLearningOs();
      container.read(appRouterProvider).go('/favorites');
      await tester.pumpAndSettle();

      expect(find.text('Favorites is on its way'), findsOneWidget);
    });

    testWidgets('root redirects to the dashboard', (tester) async {
      final container = await tester.pumpLearningOs();
      final router = container.read(appRouterProvider)..go('/notes');
      await tester.pumpAndSettle();
      router.go('/');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/dashboard');
    });

    testWidgets('unknown URLs show the not-found page', (tester) async {
      final container = await tester.pumpLearningOs();
      container.read(appRouterProvider).go('/does-not-exist');
      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);
      await tester.tap(find.text('Back to dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard is on its way'), findsOneWidget);
    });
  });

  group('preferences', () {
    testWidgets('theme selector switches to dark mode', (tester) async {
      final container = await tester.pumpLearningOs();

      await tester.tap(findTooltip('Dark'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppSidebar));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(
        container.read(settingsControllerProvider).themePreference,
        ThemePreference.dark,
      );
    });

    testWidgets('switching to Arabic localizes the UI and flips to RTL', (
      tester,
    ) async {
      final container = await tester.pumpLearningOs();

      await tester.runAsync(
        () => container
            .read(settingsControllerProvider.notifier)
            .setLanguage(AppLanguage.arabic),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppSidebar));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(find.text('المصادر'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigation state survives a theme change', (tester) async {
      final container = await tester.pumpLearningOs();
      final router = container.read(appRouterProvider);

      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      await tester.tap(findTooltip('Dark'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/categories');
    });
  });
}
