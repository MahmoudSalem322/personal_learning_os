import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/categories/domain/category_draft.dart';
import 'package:personal_learning_os/features/categories/presentation/categories_providers.dart';
import 'package:personal_learning_os/features/categories/presentation/widgets/category_card.dart';
import 'package:personal_learning_os/features/categories/presentation/widgets/category_form_dialog.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../../helpers/test_app.dart';

/// Opens /categories and returns the provider container.
Future<ProviderContainer> openCategories(
  WidgetTester tester, {
  Size size = TestViewports.desktop,
}) async {
  final container = await tester.pumpLearningOs(size: size);
  container.read(appRouterProvider).go('/categories');
  await tester.pumpAndSettle();
  return container;
}

Future<void> createCategory(ProviderContainer c, String name) => c
    .read(categoryServiceProvider)
    .create(
      CategoryDraft(
        name: name,
        icon: 'code',
        primaryColor: 0xFF3B82F6,
        secondaryColor: 0xFF0EA5E9,
      ),
    );

void main() {
  testWidgets('shows the empty state with create and sample actions', (
    tester,
  ) async {
    await openCategories(tester);

    expect(find.text('Organize your learning'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'New category'), findsWidgets);
    expect(find.text('Load sample data'), findsOneWidget);
  });

  testWidgets('loads sample data, then removes it after confirmation', (
    tester,
  ) async {
    await openCategories(tester);

    await tester.tap(find.text('Load sample data'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    expect(find.byType(CategoryCard), findsNWidgets(4));
    expect(find.text('Git & GitHub'), findsOneWidget);
    expect(find.text("You're exploring sample data"), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Remove sample data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove sample data'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    expect(find.byType(CategoryCard), findsNothing);
    expect(find.text('Organize your learning'), findsOneWidget);
  });

  testWidgets('creates a category through the form', (tester) async {
    await openCategories(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'New category').first);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryFormDialog), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Algorithms',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Sorting and graphs',
    );
    await tester.tap(findTooltip('Math'));
    await tester.tap(findTooltip('Green'));
    await tester.pump();

    await tester.tap(find.text('Create category'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    expect(find.byType(CategoryFormDialog), findsNothing);
    expect(find.text('Category created'), findsOneWidget);
    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Sorting and graphs'), findsOneWidget);
  });

  testWidgets('form shows validation errors for empty and duplicate names', (
    tester,
  ) async {
    final container = await openCategories(tester);
    await tester.io(() => createCategory(container, 'Flutter'));

    await tester.tap(find.widgetWithText(FilledButton, 'New category'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create category'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'flutter');
    await tester.tap(find.text('Create category'));
    await tester.pump();
    expect(
      find.text('A category with this name already exists'),
      findsOneWidget,
    );
    expect(find.byType(CategoryFormDialog), findsOneWidget);
  });

  testWidgets('card gives the description room for two full lines', (
    tester,
  ) async {
    final container = await openCategories(tester);
    const description =
        'A long description that certainly needs more than a single line '
        'of text inside a category card, to check nothing is clipped.';
    await tester.io(
      () => container
          .read(categoryServiceProvider)
          .create(
            const CategoryDraft(
              name: 'Flutter',
              description: description,
              icon: 'code',
              primaryColor: 0xFF3B82F6,
              secondaryColor: 0xFF0EA5E9,
            ),
          ),
    );

    final paragraph = tester.renderObject<RenderBox>(find.text(description));
    // Body text is 14px on a 22px line height.
    expect(paragraph.size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('filters by name and shows a no-results state', (tester) async {
    final container = await openCategories(tester);
    await tester.io(() async {
      await createCategory(container, 'Flutter');
      await createCategory(container, 'Dart');
    });

    expect(find.text('2 categories'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Filter categories'),
      'dar',
    );
    await tester.pump();
    expect(find.byType(CategoryCard), findsOneWidget);
    expect(find.text('1 category'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Filter categories'),
      'zzz',
    );
    await tester.pump();
    expect(find.text('No matching categories'), findsOneWidget);
  });

  testWidgets('opens the detail page and edits the category', (tester) async {
    final container = await openCategories(tester);
    await tester.io(() => createCategory(container, 'Flutter'));

    await tester.tap(find.byType(CategoryCard));
    await tester.pumpAndSettle();

    final router = container.read(appRouterProvider);
    expect(router.state.uri.path, startsWith('/categories/'));
    expect(find.text('All categories'), findsOneWidget);
    expect(find.text('No resources in Flutter yet'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Flutter Web',
    );
    await tester.tap(find.text('Save changes'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    expect(find.text('Category updated'), findsOneWidget);
    expect(find.text('Flutter Web'), findsWidgets);
  });

  testWidgets('deletes from the detail page and Undo restores it', (
    tester,
  ) async {
    final container = await openCategories(tester);
    await tester.io(() => createCategory(container, 'Flutter'));

    await tester.tap(find.byType(CategoryCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete “Flutter”?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.io(() => Future<void>.delayed(Duration.zero));

    final router = container.read(appRouterProvider);
    expect(router.state.uri.path, '/categories');
    expect(find.byType(CategoryCard), findsNothing);
    expect(find.text('Category deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.io(() => Future<void>.delayed(Duration.zero));
    expect(find.byType(CategoryCard), findsOneWidget);
  });

  testWidgets('cancelling the delete dialog keeps the category', (
    tester,
  ) async {
    final container = await openCategories(tester);
    await tester.io(() => createCategory(container, 'Flutter'));

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryCard), findsOneWidget);
  });

  testWidgets('unknown category ids show a not-found state', (tester) async {
    final container = await openCategories(tester);
    container.read(appRouterProvider).go('/categories/nope');
    await tester.pumpAndSettle();

    expect(find.text('Category not found'), findsOneWidget);
    await tester.tap(find.text('All categories'));
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).state.uri.path, '/categories');
  });

  testWidgets('renders without overflow on mobile and in Arabic', (
    tester,
  ) async {
    final container = await openCategories(tester, size: TestViewports.mobile);
    await tester.tap(find.text('Load sample data'));
    await tester.io(() => Future<void>.delayed(Duration.zero));
    expect(tester.takeException(), isNull);

    await tester.io(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLanguage(AppLanguage.arabic),
    );
    expect(find.text('مجال جديد'), findsOneWidget);
    expect(
      find.text('٤ مجالات').evaluate().isNotEmpty ||
          find.text('4 مجالات').evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    // Form on mobile opens full screen and fits.
    await tester.tap(find.text('مجال جديد'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryFormDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
