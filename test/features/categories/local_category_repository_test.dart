import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/categories/data/local_category_repository.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:sembast/sembast_memory.dart';

Category category(String id, String name) => Category(
  id: id,
  name: name,
  icon: 'folder',
  primaryColor: 0xFF3B82F6,
  secondaryColor: 0xFF0EA5E9,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  late DatabaseFactory factory;
  late Database db;
  late LocalCategoryRepository repository;

  setUp(() async {
    factory = newDatabaseFactoryMemory();
    db = await AppDatabase.open(factory);
    repository = LocalCategoryRepository(db);
  });

  tearDown(() => db.close());

  test('saves, reads and lists categories sorted by name', () async {
    await repository.save(category('b', 'dart'));
    await repository.save(category('a', 'Flutter'));
    await repository.save(category('c', 'Algorithms'));

    final names = (await repository.getAll()).map((c) => c.name);
    expect(names, ['Algorithms', 'dart', 'Flutter']);
    expect(await repository.getById('a'), category('a', 'Flutter'));
    expect(await repository.getById('missing'), isNull);
  });

  test('save replaces a category with the same id', () async {
    await repository.save(category('a', 'Flutter'));
    await repository.save(category('a', 'Flutter Web'));
    final all = await repository.getAll();
    expect(all, hasLength(1));
    expect(all.single.name, 'Flutter Web');
  });

  test('deletes one or many', () async {
    await repository.saveAll([
      category('a', 'A'),
      category('b', 'B'),
      category('c', 'C'),
    ]);
    await repository.delete('a');
    await repository.deleteAll(['b', 'missing']);
    expect((await repository.getAll()).map((c) => c.id), ['c']);
  });

  test('data survives closing and reopening the database', () async {
    await repository.save(category('a', 'Flutter'));
    await db.close();
    db = await AppDatabase.open(factory);
    expect(await LocalCategoryRepository(db).getById('a'), isNotNull);
  });

  test('watchAll emits the list and every change', () async {
    final emissions = <List<String>>[];
    final sub = repository.watchAll().listen(
      (list) => emissions.add(list.map((c) => c.name).toList()),
    );
    await pumpEventQueue();
    await repository.save(category('a', 'Flutter'));
    await pumpEventQueue();
    await repository.delete('a');
    await pumpEventQueue();
    await sub.cancel();

    expect(emissions, [
      <String>[],
      ['Flutter'],
      <String>[],
    ]);
  });

  test('watchById emits null when the category is deleted', () async {
    await repository.save(category('a', 'Flutter'));
    final values = <String?>[];
    final sub = repository.watchById('a').listen((c) => values.add(c?.name));
    await pumpEventQueue();
    await repository.delete('a');
    await pumpEventQueue();
    await sub.cancel();
    expect(values, ['Flutter', null]);
  });

  test('skips unreadable records instead of failing', () async {
    await repository.save(category('a', 'Flutter'));
    await AppStores.categories.record('broken').put(db, {'name': 42});
    final all = await repository.getAll();
    expect(all.map((c) => c.id), ['a']);
  });

  test('wraps storage failures in StorageException', () async {
    await db.close();
    expect(
      () => repository.save(category('a', 'Flutter')),
      throwsA(isA<StorageException>()),
    );
  });
}
