import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/categories/data/local_category_repository.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/sample_data/domain/sample_data_service.dart';
import 'package:personal_learning_os/features/sample_data/presentation/sample_catalog.dart';
import 'package:personal_learning_os/l10n/app_localizations_en.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late LocalCategoryRepository categories;
  late SampleDataService service;
  final now = DateTime.utc(2026, 9, 28);
  final samples = sampleCategories(AppLocalizationsEn(), now);

  Category own(String id, String name) => Category(
    id: id,
    name: name,
    icon: 'folder',
    primaryColor: 0,
    secondaryColor: 0,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    categories = LocalCategoryRepository(db);
    service = SampleDataService(categories);
  });

  tearDown(() => db.close());

  test('catalog contains the four sample categories with sample ids', () {
    expect(samples.map((c) => c.name), [
      'Flutter',
      'Dart',
      'UI/UX',
      'Git & GitHub',
    ]);
    expect(samples.every((c) => SampleDataService.isSampleId(c.id)), isTrue);
  });

  test('load adds all samples once', () async {
    expect(await service.load(categories: samples), 4);
    expect(await service.load(categories: samples), 0);
    expect(await categories.getAll(), hasLength(4));
  });

  test('load skips samples whose name the user already uses', () async {
    await categories.save(own('mine', 'flutter'));
    expect(await service.load(categories: samples), 3);
    final names = (await categories.getAll()).map((c) => c.name);
    expect(names.where((n) => n.toLowerCase() == 'flutter'), hasLength(1));
  });

  test('remove deletes only sample data', () async {
    await categories.save(own('mine', 'Algorithms'));
    await service.load(categories: samples);

    await service.remove();

    expect((await categories.getAll()).map((c) => c.id), ['mine']);
  });
}
