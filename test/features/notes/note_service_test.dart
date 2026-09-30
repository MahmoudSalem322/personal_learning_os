import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/utils/id_generator.dart';
import 'package:personal_learning_os/features/notes/data/local_note_repository.dart';
import 'package:personal_learning_os/features/notes/data/note_links.dart';
import 'package:personal_learning_os/features/notes/domain/note.dart';
import 'package:personal_learning_os/features/notes/domain/note_draft.dart';
import 'package:personal_learning_os/features/notes/domain/note_filter.dart';
import 'package:personal_learning_os/features/notes/domain/note_service.dart';
import 'package:personal_learning_os/features/resources/data/local_resource_repository.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/domain/resource_service.dart';
import 'package:sembast/sembast_memory.dart';

class _SequentialIds extends IdGenerator {
  int _next = 0;

  @override
  String next() => 'n${_next++}';
}

void main() {
  late Database db;
  late LocalNoteRepository repository;
  late NoteService service;
  late DateTime now;

  setUp(() async {
    db = await AppDatabase.open(newDatabaseFactoryMemory());
    repository = LocalNoteRepository(db);
    now = DateTime.utc(2026, 9, 28, 9);
    service = NoteService(repository, ids: _SequentialIds(), clock: () => now);
  });

  tearDown(() => db.close());

  test('model round-trips through JSON and tolerates missing fields', () {
    final note = Note(
      id: 'x',
      title: 'T',
      content: '# Hi',
      categoryId: 'c',
      resourceId: 'r',
      tags: const ['a'],
      isFavorite: true,
      createdAt: now,
      updatedAt: now,
    );
    expect(Note.fromJson(note.toJson()), note);
    final minimal = Note.fromJson({
      'id': 'y',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
    expect(minimal.isBlank, isTrue);
    expect(minimal.tags, isEmpty);
    expect(() => Note.fromJson({'id': 'z'}), throwsFormatException);
  });

  test('create makes a blank note right away', () async {
    final note = await service.create();
    expect(note.id, 'n0');
    expect(note.isBlank, isTrue);
    expect(await repository.getById('n0'), note);
  });

  test('update saves text and links, keeps favorite and createdAt', () async {
    final note = await service.create();
    await service.setFavorite(note.id, favorite: true);
    now = now.add(const Duration(minutes: 5));

    final updated = await service.update(
      note.id,
      const NoteDraft(
        title: '  Riverpod   notes ',
        content: '- [ ] try select',
        categoryId: 'c1',
        resourceId: 'r1',
        tags: ['#Flutter', 'flutter'],
      ),
    );

    expect(updated.title, 'Riverpod notes');
    expect(updated.tags, ['flutter']);
    expect(updated.categoryId, 'c1');
    expect(updated.resourceId, 'r1');
    expect(updated.isFavorite, isTrue, reason: 'autosave never unstars');
    expect(updated.createdAt, note.createdAt);
    expect(updated.updatedAt, now);
  });

  test('an unchanged draft does not bump updatedAt', () async {
    final note = await service.create(const NoteDraft(title: 'A'));
    now = now.add(const Duration(minutes: 1));
    final same = await service.update(note.id, const NoteDraft(title: 'A'));
    expect(same.updatedAt, note.updatedAt);
  });

  test('rejects oversized content and too many tags', () async {
    final note = await service.create();
    await expectLater(
      service.update(
        note.id,
        NoteDraft(
          content: 'x' * (NoteRules.contentMaxLength + 1),
          tags: [for (var i = 0; i < 11; i++) 't$i'],
        ),
      ),
      throwsA(
        isA<NoteValidationException>().having((e) => e.errors, 'errors', {
          NoteFieldError.contentTooLong,
          NoteFieldError.tooManyTags,
        }),
      ),
    );
  });

  test('discardIfBlank removes only blank notes', () async {
    final blank = await service.create();
    final written = await service.create(const NoteDraft(content: 'text'));
    expect(await service.discardIfBlank(blank.id), isTrue);
    expect(await service.discardIfBlank(written.id), isFalse);
    expect(await service.discardIfBlank('missing'), isFalse);
    expect((await repository.getAll()).map((n) => n.id), [written.id]);
  });

  test('delete and restore', () async {
    final note = await service.create(const NoteDraft(title: 'A'));
    final deleted = await service.delete(note.id);
    expect(await repository.getById(note.id), isNull);
    await service.restore(deleted);
    expect(await repository.getById(note.id), note);
    await expectLater(
      service.delete('missing'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('deleting a resource keeps its notes; Undo re-links them', () async {
    final resources = LocalResourceRepository(db);
    final resourceService = ResourceService(
      resources,
      links: [NoteResourceLinks(repository)],
    );
    final resource = await resources
        .save(
          Resource(
            id: 'r1',
            title: 'Docs',
            type: ResourceType.website,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .then((_) => 'r1');
    final note = await service.create(
      NoteDraft(title: 'About docs', resourceId: resource),
    );

    final deleted = await resourceService.delete(resource);
    expect((await repository.getById(note.id))!.resourceId, isNull);

    await resourceService.restore(deleted);
    expect((await repository.getById(note.id))!.resourceId, resource);
  });

  group('NoteFilter', () {
    final base = DateTime.utc(2026, 9, 28);
    Note n(
      String id, {
      String title = '',
      String content = '',
      String? categoryId,
      List<String> tags = const [],
      bool favorite = false,
      int updatedDay = 0,
      int createdDay = 0,
    }) => Note(
      id: id,
      title: title,
      content: content,
      categoryId: categoryId,
      tags: tags,
      isFavorite: favorite,
      createdAt: base.add(Duration(days: createdDay)),
      updatedAt: base.add(Duration(days: updatedDay)),
    );

    final all = [
      n(
        'a',
        title: 'Layout',
        content: 'Row and Column',
        categoryId: 'c1',
        tags: ['flutter'],
        updatedDay: 1,
        createdDay: 3,
      ),
      n(
        'b',
        title: 'Git',
        content: 'rebase',
        favorite: true,
        updatedDay: 3,
        createdDay: 1,
      ),
      n(
        'c',
        title: 'Dart',
        content: 'async',
        categoryId: 'c2',
        updatedDay: 2,
        createdDay: 2,
      ),
    ];

    List<String> ids(NoteFilter f) => f.apply(all).map((e) => e.id).toList();

    test('sorts by update, creation or title', () {
      expect(ids(const NoteFilter()), ['b', 'c', 'a']);
      expect(ids(const NoteFilter(sort: NoteSort.recentlyCreated)), [
        'a',
        'c',
        'b',
      ]);
      expect(ids(const NoteFilter(sort: NoteSort.title)), ['c', 'b', 'a']);
    });

    test('searches title, content and #tags; filters links and stars', () {
      expect(ids(const NoteFilter(query: 'COLUMN')), ['a']);
      expect(ids(const NoteFilter(query: '#flu')), ['a']);
      expect(ids(const NoteFilter(categoryId: 'c2')), ['c']);
      expect(ids(const NoteFilter(categoryId: NoteFilter.uncategorized)), [
        'b',
      ]);
      expect(ids(const NoteFilter(favoritesOnly: true)), ['b']);
      expect(ids(const NoteFilter(tag: 'flutter')), ['a']);
    });
  });
}
