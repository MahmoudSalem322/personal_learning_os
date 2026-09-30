import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/categories/data/local_category_repository.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/notes/data/local_note_repository.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/sample_data/domain/sample_data_service.dart';
import 'package:personal_learning_os/features/sample_data/presentation/sample_catalog.dart';
import 'package:personal_learning_os/l10n/app_localizations_en.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late LocalCategoryRepository categories;
  late LocalResourceRepository resources;
  late LocalNoteRepository notes;
  late SampleDataService service;
  final now = DateTime.utc(2026, 9, 28);
  final l10n = AppLocalizationsEn();
  final sampleCats = sampleCategories(l10n, now);
  final sampleRes = sampleResources(l10n, now);
  final sampleNts = sampleNotes(l10n, now);

  Future<int> loadAll() => service.load(
    categories: sampleCats,
    resources: sampleRes,
    notes: sampleNts,
  );

  Category ownCategory(String id, String name) => Category(
    id: id,
    name: name,
    icon: 'folder',
    primaryColor: 0,
    secondaryColor: 0,
    createdAt: now,
    updatedAt: now,
  );

  Resource ownResource(String id, {String? categoryId}) => Resource(
    id: id,
    title: 'Mine',
    type: ResourceType.website,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    categories = LocalCategoryRepository(db);
    resources = LocalResourceRepository(db);
    notes = LocalNoteRepository(db);
    service = SampleDataService(
      categories: categories,
      resources: resources,
      notes: notes,
    );
  });

  tearDown(() => db.close());

  test('catalog: four categories and resources linked to them', () {
    expect(sampleCats.map((c) => c.name), [
      'Flutter',
      'Dart',
      'UI/UX',
      'Git & GitHub',
    ]);
    final categoryIds = sampleCats.map((c) => c.id).toSet();
    expect(sampleRes, isNotEmpty);
    expect(sampleRes.every((r) => categoryIds.contains(r.categoryId)), isTrue);
    expect(
      [
        ...sampleCats.map((c) => c.id),
        ...sampleRes.map((r) => r.id),
      ].every(SampleDataService.isSampleId),
      isTrue,
    );
  });

  test('load adds everything once', () async {
    expect(
      await loadAll(),
      sampleCats.length + sampleRes.length + sampleNts.length,
    );
    expect(await loadAll(), 0);
    expect(await categories.getAll(), hasLength(sampleCats.length));
    expect(await resources.getAll(), hasLength(sampleRes.length));
    expect(await notes.getAll(), hasLength(sampleNts.length));
  });

  test('skips categories whose name the user already uses', () async {
    await categories.save(ownCategory('mine', 'flutter'));
    await loadAll();

    final names = (await categories.getAll()).map((c) => c.name.toLowerCase());
    expect(names.where((n) => n == 'flutter'), hasLength(1));
    // Sample Flutter resources are still added, just without a category.
    final flutterDocs = await resources.getById('sample-resource-flutter-docs');
    expect(flutterDocs, isNotNull);
    expect(flutterDocs!.categoryId, isNull);
  });

  test('sample notes link to sample categories and resources', () {
    final resourceIds = sampleRes.map((r) => r.id).toSet();
    expect(sampleNts, isNotEmpty);
    expect(sampleNts.every((n) => resourceIds.contains(n.resourceId)), isTrue);
    expect(sampleNts.every((n) => n.content.isNotEmpty), isTrue);
  });

  test('remove keeps user notes and drops their sample links', () async {
    await loadAll();
    await notes.save(
      Note(
        id: 'my-note',
        title: 'Mine',
        categoryId: 'sample-category-flutter',
        resourceId: 'sample-resource-riverpod',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await service.remove();

    final remaining = await notes.getAll();
    expect(remaining.map((n) => n.id), ['my-note']);
    expect(remaining.single.categoryId, isNull);
    expect(remaining.single.resourceId, isNull);
  });

  test('remove deletes only sample data and keeps user resources', () async {
    await categories.save(ownCategory('mine', 'Algorithms'));
    await loadAll();
    // The user filed their own resource under a sample category.
    await resources.save(
      ownResource('my-resource', categoryId: 'sample-category-dart'),
    );

    await service.remove();

    expect((await categories.getAll()).map((c) => c.id), ['mine']);
    final remaining = await resources.getAll();
    expect(remaining.map((r) => r.id), ['my-resource']);
    expect(remaining.single.categoryId, isNull);
  });
}
