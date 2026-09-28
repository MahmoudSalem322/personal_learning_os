import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:sembast/sembast_memory.dart';

Resource resource(String id, {String? categoryId, int day = 0}) => Resource(
  id: id,
  title: id,
  type: ResourceType.website,
  categoryId: categoryId,
  createdAt: DateTime.utc(2026, 9, 1 + day),
  updatedAt: DateTime.utc(2026, 9, 1 + day),
);

void main() {
  late DatabaseFactory factory;
  late Database db;
  late LocalResourceRepository repository;

  setUp(() async {
    factory = newDatabaseFactoryMemory();
    db = await AppDatabase.open(factory);
    repository = LocalResourceRepository(db);
  });

  tearDown(() => db.close());

  test('lists newest first and survives reopening', () async {
    await repository.saveAll([
      resource('old'),
      resource('new', day: 2),
      resource('mid', day: 1),
    ]);
    expect((await repository.getAll()).map((r) => r.id), ['new', 'mid', 'old']);

    await db.close();
    db = await AppDatabase.open(factory);
    expect(await LocalResourceRepository(db).getAll(), hasLength(3));
  });

  test('clearCategory unlinks only matching resources', () async {
    await repository.saveAll([
      resource('a', categoryId: 'c1'),
      resource('b', categoryId: 'c1'),
      resource('c', categoryId: 'c2'),
      resource('d'),
    ]);

    final changed = await repository.clearCategory('c1');

    expect(changed, unorderedEquals(['a', 'b']));
    final byId = {for (final r in await repository.getAll()) r.id: r};
    expect(byId['a']!.categoryId, isNull);
    expect(byId['b']!.categoryId, isNull);
    expect(byId['c']!.categoryId, 'c2');
    // Other fields are untouched.
    expect(byId['a']!.title, 'a');
  });

  test('assignCategory skips resources deleted in the meantime', () async {
    await repository.saveAll([resource('a'), resource('b')]);
    await repository.delete('b');

    await repository.assignCategory('c1', ['a', 'b']);

    final all = await repository.getAll();
    expect(all.map((r) => r.id), ['a']);
    expect(all.single.categoryId, 'c1');
  });

  test('watchById follows changes', () async {
    await repository.save(resource('a'));
    final values = <int?>[];
    final sub = repository
        .watchById('a')
        .listen((r) => values.add(r?.progress));
    await pumpEventQueue();
    await repository.save(resource('a').copyWith(progress: 30));
    await pumpEventQueue();
    await repository.delete('a');
    await pumpEventQueue();
    await sub.cancel();
    expect(values, [0, 30, null]);
  });
}
