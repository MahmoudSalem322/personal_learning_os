import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/core/services/file_service.dart';
import 'package:personal_learning_os/features/backup/domain/backup_codec.dart';
import 'package:personal_learning_os/features/backup/domain/backup_snapshot.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/categories/domain/category_draft.dart';
import 'package:personal_learning_os/features/categories/presentation/categories_providers.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

import '../../helpers/test_app.dart';

/// Tall enough to show every settings section.
const Size _tall = Size(1440, 1600);

Future<ProviderContainer> openSettings(
  WidgetTester tester,
  FakeFileService files, {
  Size size = _tall,
}) async {
  final container = await tester.pumpLearningOs(size: size, fileService: files);
  container.read(appRouterProvider).go('/settings');
  await tester.pumpAndSettle();
  return container;
}

Future<void> addCategory(
  WidgetTester tester,
  ProviderContainer container,
  String name,
) => tester.io(
  () => container
      .read(categoryServiceProvider)
      .create(
        CategoryDraft(
          name: name,
          icon: 'code',
          primaryColor: 0xFF8B5CF6,
          secondaryColor: 0xFF6366F1,
        ),
      ),
);

Future<List<Category>> storedCategories(
  WidgetTester tester,
  ProviderContainer container,
) => tester.io(() => container.read(categoryRepositoryProvider).getAll());

PickedTextFile backupFile(BackupSnapshot snapshot) => PickedTextFile(
  name: 'backup.json',
  content: BackupCodec.encode(snapshot, now: DateTime.utc(2026, 9, 29, 9)),
);

Category category(String id, String name) => Category(
  id: id,
  name: name,
  icon: 'code',
  primaryColor: 0xFF8B5CF6,
  secondaryColor: 0xFF6366F1,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

void main() {
  testWidgets('shows preferences, data tools and about', (tester) async {
    await openSettings(tester, FakeFileService());
    for (final text in [
      'Appearance & language',
      'Notification preferences',
      'Export backup',
      'Import backup',
      'Clear all data',
      'Version 1.0.0',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('export downloads a JSON backup of everything', (tester) async {
    final files = FakeFileService();
    final container = await openSettings(tester, files);
    await addCategory(tester, container, 'Algorithms');

    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Export'));

    final file = files.saved.single;
    expect(file.name, startsWith('learning-os-backup-'));
    expect(file.name, endsWith('.json'));
    final json = jsonDecode(file.content) as Map<String, Object?>;
    expect(json['app'], 'learning-os');
    expect(
      (json['categories']! as List).single,
      containsPair('name', 'Algorithms'),
    );
    expect(find.text('Backup downloaded'), findsOneWidget);
  });

  testWidgets('import: preview, then merge', (tester) async {
    final files = FakeFileService()
      ..nextPick = backupFile(
        BackupSnapshot(categories: [category('from-file', 'Imported')]),
      );
    final container = await openSettings(tester, files);
    await addCategory(tester, container, 'Mine');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Import'));
    await tester.pumpAndSettle();
    expect(find.text('backup.json'), findsOneWidget);
    expect(find.textContaining('Exported'), findsOneWidget);

    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Merge'));

    final names = (await storedCategories(
      tester,
      container,
    )).map((c) => c.name);
    expect(names, containsAll(['Mine', 'Imported']));
    expect(find.text('Backup merged'), findsOneWidget);
  });

  testWidgets('import: replace applies the backup settings; Undo reverts', (
    tester,
  ) async {
    final files = FakeFileService()
      ..nextPick = backupFile(
        BackupSnapshot(
          settings: const AppSettings(language: AppLanguage.arabic),
          categories: [category('from-file', 'Imported')],
        ),
      );
    final container = await openSettings(tester, files);
    await addCategory(tester, container, 'Mine');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Import'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Replace'));
    await tester.pumpAndSettle();
    expect(find.text('Replace all your data?'), findsOneWidget);
    await tester.tapAndSettleIo(find.widgetWithText(FilledButton, 'Replace'));

    expect((await storedCategories(tester, container)).map((c) => c.name), [
      'Imported',
    ]);
    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.arabic,
    );

    // The toast was shown before the language switched.
    await tester.tapAndSettleIo(find.text('Undo'));
    expect((await storedCategories(tester, container)).map((c) => c.name), [
      'Mine',
    ]);
    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.system,
    );
  });

  testWidgets('an invalid file is explained and nothing changes', (
    tester,
  ) async {
    final files = FakeFileService()
      ..nextPick = const PickedTextFile(
        name: 'notes.json',
        content: '{"hello": "world"}',
      );
    final container = await openSettings(tester, files);
    await addCategory(tester, container, 'Mine');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Import'));
    await tester.pumpAndSettle();

    expect(find.text("Can't import this file"), findsOneWidget);
    expect(
      find.textContaining("This isn't a Learning OS backup file."),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect((await storedCategories(tester, container)).single.name, 'Mine');
  });

  testWidgets('cancelling the file picker does nothing', (tester) async {
    await openSettings(tester, FakeFileService());
    await tester.tap(find.widgetWithText(OutlinedButton, 'Import'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('clear all data, then Undo', (tester) async {
    final container = await openSettings(tester, FakeFileService());
    await addCategory(tester, container, 'Mine');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear data'));
    await tester.pumpAndSettle();
    await tester.tapAndSettleIo(
      find.widgetWithText(FilledButton, 'Clear all data'),
    );
    expect(await storedCategories(tester, container), isEmpty);
    expect(find.text('All data cleared'), findsOneWidget);

    await tester.tapAndSettleIo(find.text('Undo'));
    expect((await storedCategories(tester, container)).single.name, 'Mine');
  });

  testWidgets('fits on small phones', (tester) async {
    await openSettings(tester, FakeFileService(), size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
}
