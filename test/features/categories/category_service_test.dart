import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/utils/id_generator.dart';
import 'package:personal_learning_os/features/categories/data/local_category_repository.dart';
import 'package:personal_learning_os/features/categories/domain/category.dart';
import 'package:personal_learning_os/features/categories/domain/category_draft.dart';
import 'package:personal_learning_os/features/categories/domain/category_service.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/data/resource_category_links.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:sembast/sembast_memory.dart';

class _SequentialIds extends IdGenerator {
  int _next = 0;

  @override
  String next() => 'id-${_next++}';
}

CategoryDraft draft(String name, {String description = ''}) => CategoryDraft(
  name: name,
  description: description,
  icon: 'code',
  primaryColor: 0xFF8B5CF6,
  secondaryColor: 0xFF6366F1,
);

void main() {
  late Database db;
  late LocalCategoryRepository repository;
  late LocalResourceRepository resources;
  late CategoryService service;
  late DateTime now;

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    repository = LocalCategoryRepository(db);
    resources = LocalResourceRepository(db);
    now = DateTime.utc(2026, 9, 28, 9);
    service = CategoryService(
      repository,
      links: [ResourceCategoryLinks(resources)],
      ids: _SequentialIds(),
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  group('create', () {
    test('persists a normalized category with id and timestamps', () async {
      final created = await service.create(
        draft('  Flutter   Web  ', description: '  Widgets  '),
      );

      expect(created.id, 'id-0');
      expect(created.name, 'Flutter Web');
      expect(created.description, 'Widgets');
      expect(created.createdAt, now);
      expect(created.updatedAt, now);
      expect(await repository.getById('id-0'), created);
    });

    test('rejects an empty name', () async {
      await expectLater(
        service.create(draft('   ')),
        throwsA(
          isA<CategoryValidationException>().having((e) => e.errors, 'errors', {
            CategoryFieldError.nameRequired,
          }),
        ),
      );
      expect(await repository.getAll(), isEmpty);
    });

    test('rejects names and descriptions over the limits', () async {
      await expectLater(
        service.create(
          draft(
            'x' * (CategoryRules.nameMaxLength + 1),
            description: 'y' * (CategoryRules.descriptionMaxLength + 1),
          ),
        ),
        throwsA(
          isA<CategoryValidationException>().having((e) => e.errors, 'errors', {
            CategoryFieldError.nameTooLong,
            CategoryFieldError.descriptionTooLong,
          }),
        ),
      );
    });

    test('rejects duplicate names, ignoring case and spacing', () async {
      await service.create(draft('Flutter'));
      await expectLater(
        service.create(draft('  flutter ')),
        throwsA(
          isA<CategoryValidationException>().having((e) => e.errors, 'errors', {
            CategoryFieldError.nameTaken,
          }),
        ),
      );
    });
  });

  group('update', () {
    test('changes fields, keeps createdAt and bumps updatedAt', () async {
      final created = await service.create(draft('Flutter'));
      now = now.add(const Duration(hours: 2));

      final updated = await service.update(
        created.id,
        draft('Flutter Web', description: 'Web target'),
      );

      expect(updated.name, 'Flutter Web');
      expect(updated.description, 'Web target');
      expect(updated.createdAt, created.createdAt);
      expect(updated.updatedAt, now);
      expect(await repository.getById(created.id), updated);
    });

    test('allows keeping its own name', () async {
      final created = await service.create(draft('Flutter'));
      final updated = await service.update(
        created.id,
        draft('FLUTTER', description: 'x'),
      );
      expect(updated.name, 'FLUTTER');
    });

    test('keeps the timestamp when nothing changed', () async {
      final created = await service.create(draft('Flutter'));
      now = now.add(const Duration(hours: 1));
      final same = await service.update(created.id, draft('Flutter'));
      expect(same.updatedAt, created.updatedAt);
    });

    test('rejects taking another category name', () async {
      await service.create(draft('Flutter'));
      final dart = await service.create(draft('Dart'));
      await expectLater(
        service.update(dart.id, draft('flutter')),
        throwsA(isA<CategoryValidationException>()),
      );
    });

    test('throws NotFoundException for unknown ids', () async {
      await expectLater(
        service.update('missing', draft('X')),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('delete and restore', () {
    test(
      'delete returns the removed category and restore brings it back',
      () async {
        final created = await service.create(draft('Flutter'));
        final deleted = await service.delete(created.id);

        expect(deleted.category, created);
        expect(await repository.getById(created.id), isNull);

        await service.restore(deleted);
        expect(await repository.getById(created.id), created);
      },
    );

    test('keeps resources (uncategorized) and Undo re-links them', () async {
      final flutter = await service.create(draft('Flutter'));
      final dart = await service.create(draft('Dart'));
      Resource resource(String id, String? categoryId) => Resource(
        id: id,
        title: id,
        type: ResourceType.website,
        categoryId: categoryId,
        createdAt: now,
        updatedAt: now,
      );
      await resources.saveAll([
        resource('r1', flutter.id),
        resource('r2', flutter.id),
        resource('r3', dart.id),
      ]);

      final deleted = await service.delete(flutter.id);

      expect(deleted.detachedCount, 2);
      final afterDelete = {
        for (final r in await resources.getAll()) r.id: r.categoryId,
      };
      expect(afterDelete, {'r1': null, 'r2': null, 'r3': dart.id});

      await service.restore(deleted);

      final afterUndo = {
        for (final r in await resources.getAll()) r.id: r.categoryId,
      };
      expect(afterUndo, {'r1': flutter.id, 'r2': flutter.id, 'r3': dart.id});
    });

    test('deleting an unknown id throws NotFoundException', () async {
      await expectLater(
        service.delete('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  test('filterCategories matches name or description, case-insensitive', () {
    Category c(String name, String description) => Category(
      id: name,
      name: name,
      description: description,
      icon: 'folder',
      primaryColor: 0,
      secondaryColor: 0,
      createdAt: now,
      updatedAt: now,
    );
    final all = [c('Flutter', 'Widgets'), c('Dart', 'Language'), c('Git', '')];

    expect(filterCategories(all, ''), all);
    expect(filterCategories(all, 'FLU').map((c) => c.name), ['Flutter']);
    expect(filterCategories(all, 'language').map((c) => c.name), ['Dart']);
    expect(filterCategories(all, 'zzz'), isEmpty);
  });
}
