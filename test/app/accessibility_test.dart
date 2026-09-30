import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../helpers/test_app.dart';

/// WCAG 2.2 AA "Target Size (Minimum)": every tappable at least 24x24.
const wcagTargetSize = MinimumTapTargetGuideline(
  size: Size(24, 24),
  link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum',
);

/// Every top-level page and a detail page of each kind (sample ids).
const _paths = [
  '/dashboard',
  '/notifications',
  '/categories',
  '/categories/sample-category-flutter',
  '/resources',
  '/resources/sample-resource-riverpod',
  '/notes',
  '/tasks',
  '/tasks/sample-task-learn-riverpod',
  '/favorites',
  '/settings',
];

Future<ProviderContainer> withSamples(
  WidgetTester tester, {
  required Size size,
  required ThemePreference theme,
}) async {
  final container = await tester.pumpLearningOs(size: size);
  await tester.tapAndSettleIo(find.text('Load sample data'));
  await tester.io(
    () => container
        .read(settingsControllerProvider.notifier)
        .setThemePreference(theme),
  );
  return container;
}

Future<void> checkPages(
  WidgetTester tester,
  ProviderContainer container, {
  required List<AccessibilityGuideline> guidelines,
}) async {
  for (final path in _paths) {
    container.read(appRouterProvider).go(path);
    await tester.pumpAndSettle();
    for (final guideline in guidelines) {
      await expectLater(
        tester,
        meetsGuideline(guideline),
        reason: '$path: ${guideline.description}',
      );
    }
  }
}

void main() {
  for (final theme in [ThemePreference.light, ThemePreference.dark]) {
    testWidgets('desktop, ${theme.name}: labels and contrast', (tester) async {
      final handle = tester.ensureSemantics();
      final container = await withSamples(
        tester,
        size: TestViewports.desktop,
        theme: theme,
      );
      await checkPages(
        tester,
        container,
        guidelines: [labeledTapTargetGuideline, textContrastGuideline],
      );
      handle.dispose();
    });

    testWidgets('phone, ${theme.name}: labels, contrast and target size', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final container = await withSamples(
        tester,
        size: TestViewports.mobile,
        theme: theme,
      );
      await checkPages(
        tester,
        container,
        guidelines: [
          labeledTapTargetGuideline,
          textContrastGuideline,
          wcagTargetSize,
        ],
      );
      handle.dispose();
    });
  }
}
