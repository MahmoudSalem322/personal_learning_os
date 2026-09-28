import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/utils/id_generator.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_draft.dart';
import 'package:personal_learning_os/features/resources/domain/resource_service.dart';
import 'package:sembast/sembast_memory.dart';

class _SequentialIds extends IdGenerator {
  int _next = 0;

  @override
  String next() => 'r${_next++}';
}

ResourceDraft draft({
  String title = 'Riverpod',
  String url = '',
  List<String> tags = const [],
  int progress = 0,
  String description = '',
}) => ResourceDraft(
  title: title,
  url: url,
  type: ResourceType.website,
  tags: tags,
  progress: progress,
  description: description,
);

Matcher rejects(Set<ResourceFieldError> errors) => throwsA(
  isA<ResourceValidationException>().having((e) => e.errors, 'errors', errors),
);

void main() {
  late Database db;
  late LocalResourceRepository repository;
  late ResourceService service;
  late DateTime now;

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    repository = LocalResourceRepository(db);
    now = DateTime.utc(2026, 9, 28, 9);
    service = ResourceService(
      repository,
      ids: _SequentialIds(),
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  group('create', () {
    test('normalizes input and stores timestamps', () async {
      final r = await service.create(
        draft(
          title: '  Riverpod   docs ',
          url: 'riverpod.dev',
          tags: ['#Flutter', 'flutter', 'State Management'],
          progress: 140,
        ),
      );
      expect(r.id, 'r0');
      expect(r.title, 'Riverpod docs');
      expect(r.url, 'https://riverpod.dev');
      expect(r.tags, ['flutter', 'state-management']);
      expect(r.progress, 100);
      expect(r.createdAt, now);
      expect(r.lastOpenedAt, isNull);
      expect(await repository.getById('r0'), r);
    });

    test('uses the site name when only a link is given', () async {
      final r = await service.create(
        draft(title: '', url: 'https://www.youtube.com/@flutterdev'),
      );
      expect(r.title, 'youtube.com');
    });

    test('requires a title or a link', () async {
      await expectLater(
        service.create(draft(title: ' ')),
        rejects({ResourceFieldError.titleRequired}),
      );
    });

    test('rejects invalid links, long fields and too many tags', () async {
      await expectLater(
        service.create(draft(url: 'not a url')),
        rejects({ResourceFieldError.urlInvalid}),
      );
      await expectLater(
        service.create(
          draft(
            title: 'x' * (ResourceRules.titleMaxLength + 1),
            description: 'y' * (ResourceRules.descriptionMaxLength + 1),
            tags: [for (var i = 0; i < 11; i++) 'tag$i'],
          ),
        ),
        rejects({
          ResourceFieldError.titleTooLong,
          ResourceFieldError.descriptionTooLong,
          ResourceFieldError.tooManyTags,
        }),
      );
      expect(await repository.getAll(), isEmpty);
    });
  });

  test('update changes fields and bumps updatedAt only on change', () async {
    final r = await service.create(draft());
    now = now.add(const Duration(hours: 1));

    final same = await service.update(r.id, draft());
    expect(same.updatedAt, r.updatedAt);

    final changed = await service.update(r.id, draft(title: 'Riverpod 3'));
    expect(changed.title, 'Riverpod 3');
    expect(changed.createdAt, r.createdAt);
    expect(changed.updatedAt, now);
  });

  test('setProgress clamps and bumps updatedAt', () async {
    final r = await service.create(draft());
    now = now.add(const Duration(minutes: 5));
    final done = await service.setProgress(r.id, 120);
    expect(done.progress, 100);
    expect(done.updatedAt, now);
  });

  test('setFavorite does not count as an edit', () async {
    final r = await service.create(draft());
    now = now.add(const Duration(minutes: 5));
    final starred = await service.setFavorite(r.id, favorite: true);
    expect(starred.isFavorite, isTrue);
    expect(starred.updatedAt, r.updatedAt);
  });

  test('markOpened records the time', () async {
    final r = await service.create(draft(url: 'https://riverpod.dev'));
    now = now.add(const Duration(days: 1));
    await service.markOpened(r.id);
    expect((await repository.getById(r.id))!.lastOpenedAt, now);
  });

  test('delete returns the resource and restore brings it back', () async {
    final r = await service.create(draft());
    final deleted = await service.delete(r.id);
    expect(await repository.getById(r.id), isNull);
    await service.restore(deleted);
    expect(await repository.getById(r.id), r);
  });

  test('operations on unknown ids throw NotFoundException', () async {
    await expectLater(
      service.setProgress('missing', 10),
      throwsA(isA<NotFoundException>()),
    );
    await expectLater(
      service.delete('missing'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
