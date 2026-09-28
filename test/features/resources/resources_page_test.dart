import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/categories/domain/category_draft.dart';
import 'package:personal_learning_os/features/categories/presentation/categories_providers.dart';
import 'package:personal_learning_os/features/categories/presentation/widgets/category_card.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_card.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_form_dialog.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../../helpers/test_app.dart';

Future<ProviderContainer> open(
  WidgetTester tester,
  String path, {
  Size size = TestViewports.desktop,
  FakeUrlOpener? opener,
}) async {
  final container = await tester.pumpLearningOs(size: size, urlOpener: opener);
  container.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
  return container;
}

Future<Resource> addResource(
  ProviderContainer c,
  String title, {
  String url = '',
  String? categoryId,
  ResourceType type = ResourceType.website,
  bool favorite = false,
  int progress = 0,
}) => c
    .read(resourceServiceProvider)
    .create(
      ResourceDraft(
        title: title,
        url: url,
        type: type,
        categoryId: categoryId,
        isFavorite: favorite,
        progress: progress,
      ),
    );

Future<String> addCategory(ProviderContainer c, String name) async =>
    (await c
            .read(categoryServiceProvider)
            .create(
              CategoryDraft(
                name: name,
                icon: 'code',
                primaryColor: 0xFF3B82F6,
                secondaryColor: 0xFF0EA5E9,
              ),
            ))
        .id;

void main() {
  testWidgets('empty library offers to add a resource or load samples', (
    tester,
  ) async {
    await open(tester, '/resources');
    expect(find.text('Your learning library is empty'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add resource'), findsWidgets);
    expect(find.text('Load sample data'), findsOneWidget);
  });

  testWidgets('adds a resource from just a link', (tester) async {
    await open(tester, '/resources');

    await tester.tap(find.widgetWithText(FilledButton, 'Add resource').first);
    await tester.pumpAndSettle();
    expect(find.byType(ResourceFormDialog), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Link'),
      'youtube.com/@flutterdev',
    );
    await tester.pump();
    // Type is detected from the link.
    final youtubeChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'YouTube'),
    );
    expect(youtubeChip.selected, isTrue);

    await tester.tapAndSettleIo(find.text('Add resource').last);

    expect(find.byType(ResourceFormDialog), findsNothing);
    expect(find.text('Resource added'), findsOneWidget);
    expect(find.byType(ResourceCard), findsOneWidget);
    expect(find.text('youtube.com'), findsWidgets);
  });

  testWidgets('form rejects an invalid link', (tester) async {
    await open(tester, '/resources');
    await tester.tap(find.widgetWithText(FilledButton, 'Add resource').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Link'), 'not a url');
    await tester.tap(find.text('Add resource').last);
    await tester.pump();

    expect(
      find.text('Enter a valid web address, like https://example.com'),
      findsOneWidget,
    );
    expect(find.byType(ResourceFormDialog), findsOneWidget);
  });

  testWidgets('adds tags with Enter and removes them', (tester) async {
    await open(tester, '/resources');
    await tester.tap(find.widgetWithText(FilledButton, 'Add resource').first);
    await tester.pumpAndSettle();

    final tagField = find.widgetWithText(TextField, 'Tags');
    await tester.ensureVisible(tagField);
    await tester.pumpAndSettle();
    await tester.enterText(tagField, 'State Management');
    await tester.pump();
    // A space finishes a tag, so typing it splits into two.
    expect(find.text('#state'), findsOneWidget);
    await tester.enterText(tagField, 'flutter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('#flutter'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove tag flutter'));
    await tester.pump();
    expect(find.text('#flutter'), findsNothing);
  });

  testWidgets('opening a resource opens a tab and records it', (tester) async {
    final opener = FakeUrlOpener();
    final container = await open(tester, '/resources', opener: opener);
    final r = await tester.io(
      () => addResource(container, 'Riverpod', url: 'https://riverpod.dev'),
    );

    await tester.tapAndSettleIo(find.widgetWithText(TextButton, 'Open'));

    expect(opener.opened, ['https://riverpod.dev']);
    final stored = await tester.io(
      () => container.read(resourceRepositoryProvider).getById(r.id),
    );
    expect(stored!.lastOpenedAt, isNotNull);
  });

  testWidgets('a blocked pop-up shows a hint instead of failing silently', (
    tester,
  ) async {
    final opener = FakeUrlOpener()..allow = false;
    final container = await open(tester, '/resources', opener: opener);
    await tester.io(
      () => addResource(container, 'Riverpod', url: 'https://riverpod.dev'),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Open'));
    await tester.pump();

    expect(find.textContaining('blocked the new tab'), findsOneWidget);
  });

  testWidgets('favorites toggle and the favorites filter', (tester) async {
    final container = await open(tester, '/resources');
    await tester.io(() async {
      await addResource(container, 'Alpha');
      await addResource(container, 'Beta');
    });

    await tester.tapAndSettleIo(find.byTooltip('Add to favorites').first);
    await tester.tap(find.widgetWithText(FilterChip, 'Favorites'));
    await tester.pumpAndSettle();

    expect(find.byType(ResourceCard), findsOneWidget);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
  });

  testWidgets('filters by type and clears filters', (tester) async {
    final container = await open(tester, '/resources');
    await tester.io(() async {
      await addResource(container, 'Book one', type: ResourceType.book);
      await addResource(container, 'Site one');
    });
    expect(find.text('2 resources'), findsOneWidget);

    await tester.tap(find.text('Type'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Book'));
    await tester.pumpAndSettle();

    expect(find.byType(ResourceCard), findsOneWidget);
    expect(find.text('Type: Book'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceCard), findsNWidgets(2));
  });

  testWidgets('detail page updates progress and deletes with Undo', (
    tester,
  ) async {
    final container = await open(tester, '/resources');
    await tester.io(() => addResource(container, 'Pro Git', progress: 10));

    await tester.tap(find.byType(ResourceCard));
    await tester.pumpAndSettle();
    expect(find.text('All resources'), findsOneWidget);
    // Quick steps sit side by side on one row.
    final rowY = {
      for (final step in ['0%', '25%', '50%', '75%'])
        tester.getTopLeft(find.text(step)).dy,
    };
    expect(rowY, hasLength(1));

    await tester.tapAndSettleIo(find.text('100%'));
    final stored = await tester.io(
      () => container.read(resourceRepositoryProvider).getAll(),
    );
    expect(stored.single.progress, 100);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Delete'));

    expect(container.read(appRouterProvider).state.uri.path, '/resources');
    expect(find.text('Resource deleted'), findsOneWidget);
    await tester.tapAndSettleIo(find.text('Undo'));
    expect(find.byType(ResourceCard), findsOneWidget);
  });

  testWidgets('category shows its resources and progress', (tester) async {
    final container = await open(tester, '/categories');
    await tester.io(() async {
      final id = await addCategory(container, 'Flutter');
      await addResource(container, 'Docs', categoryId: id, progress: 100);
      await addResource(container, 'Video', categoryId: id);
    });

    // Card: 2 resources, mean progress 50%.
    final card = find.byType(CategoryCard);
    expect(
      find.descendant(of: card, matching: find.text('2 resources')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('50%')),
      findsOneWidget,
    );

    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(ResourceCard), findsNWidgets(2));
  });

  testWidgets('adding from a category pre-selects it', (tester) async {
    final container = await open(tester, '/categories');
    final id = await tester.io(() => addCategory(container, 'Flutter'));
    container.read(appRouterProvider).go('/categories/$id');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add resource'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Docs');
    await tester.tapAndSettleIo(find.text('Add resource').last);

    final stored = await tester.io(
      () => container.read(resourceRepositoryProvider).getAll(),
    );
    expect(stored.single.categoryId, id);
    expect(find.byType(ResourceCard), findsOneWidget);
  });

  testWidgets('deleting a category keeps its resources; Undo relinks', (
    tester,
  ) async {
    final container = await open(tester, '/categories');
    final id = await tester.io(() async {
      final id = await addCategory(container, 'Flutter');
      await addResource(container, 'Docs', categoryId: id);
      return id;
    });

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Its resource will stay in your library'),
      findsOneWidget,
    );
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Delete'));

    var stored = await tester.io(
      () => container.read(resourceRepositoryProvider).getAll(),
    );
    expect(stored.single.categoryId, isNull);

    await tester.tapAndSettleIo(find.text('Undo'));
    stored = await tester.io(
      () => container.read(resourceRepositoryProvider).getAll(),
    );
    expect(stored.single.categoryId, id);
  });

  testWidgets('sample data fills the library; mobile and Arabic fit', (
    tester,
  ) async {
    final container = await open(
      tester,
      '/resources',
      size: TestViewports.mobile,
    );
    await tester.tapAndSettleIo(find.text('Load sample data'));
    expect(find.byType(ResourceCard), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.io(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLanguage(AppLanguage.arabic),
    );
    expect(find.text('إضافة مصدر'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ResourceCard).first);
    await tester.pumpAndSettle();
    expect(find.text('كل المصادر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
