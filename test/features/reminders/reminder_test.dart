import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/utils/id_generator.dart';
import 'package:personal_learning_os/features/reminders/data/local_reminder_repository.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder_draft.dart';
import 'package:personal_learning_os/features/reminders/domain/reminder_service.dart';
import 'package:sembast/sembast_memory.dart';

class _SequentialIds extends IdGenerator {
  int _next = 0;

  @override
  String next() => 'r-${_next++}';
}

Reminder reminder({
  required DateTime remindAt,
  ReminderRepeat repeat = ReminderRepeat.none,
  bool enabled = true,
  DateTime? lastFiredAt,
}) => Reminder(
  id: 'r',
  target: ReminderTarget.session,
  title: 'Practice',
  remindAt: remindAt,
  repeat: repeat,
  isEnabled: enabled,
  lastFiredAt: lastFiredAt,
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
);

void main() {
  final now = DateTime(2026, 9, 30, 10);

  group('model', () {
    test('is due once its time has come, unless paused or finished', () {
      expect(reminder(remindAt: now).isDue(now), isTrue);
      expect(
        reminder(remindAt: now.add(const Duration(minutes: 1))).isDue(now),
        isFalse,
      );
      expect(reminder(remindAt: now, enabled: false).isDue(now), isFalse);
      expect(reminder(remindAt: now, lastFiredAt: now).isDue(now), isFalse);
      expect(
        reminder(
          remindAt: now,
          repeat: ReminderRepeat.daily,
          lastFiredAt: now,
        ).isDue(now),
        isTrue,
        reason: 'a repeating reminder is never finished',
      );
    });

    test('next occurrence skips missed ones and keeps the time', () {
      final daily = reminder(
        remindAt: DateTime(2026, 9, 25, 20, 30),
        repeat: ReminderRepeat.daily,
      );
      expect(daily.nextAfter(now), DateTime(2026, 9, 30, 20, 30));

      final weekly = reminder(
        remindAt: DateTime(2026, 9, 16, 9),
        repeat: ReminderRepeat.weekly,
      );
      expect(weekly.nextAfter(now), DateTime(2026, 10, 7, 9));
    });

    test('survives a JSON round trip', () {
      final r = Reminder(
        id: 'x',
        target: ReminderTarget.task,
        targetId: 't1',
        title: 'Read chapter 2',
        remindAt: DateTime.utc(2026, 10, 1, 7),
        repeat: ReminderRepeat.weekly,
        isEnabled: false,
        lastFiredAt: DateTime.utc(2026, 9, 24, 7),
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 2),
      );
      expect(Reminder.fromJson(r.toJson()), r);
    });

    test('unknown values fall back to safe defaults', () {
      final r = Reminder.fromJson({
        'id': 'x',
        'target': 'calendar',
        'repeat': 'hourly',
        'remindAt': '2026-10-01T07:00:00.000Z',
        'createdAt': '2026-09-01T00:00:00.000Z',
        'updatedAt': '2026-09-01T00:00:00.000Z',
      });
      expect(r.target, ReminderTarget.session);
      expect(r.repeat, ReminderRepeat.none);
      expect(r.isEnabled, isTrue);
    });
  });

  group('service', () {
    late Database db;
    late LocalReminderRepository repository;
    late ReminderService service;

    setUp(() async {
      db = await AppDatabase.open(newDatabaseFactoryMemory());
      repository = LocalReminderRepository(db);
      service = ReminderService(
        repository,
        ids: _SequentialIds(),
        clock: () => now,
      );
    });

    tearDown(() => db.close());

    test('validates label, target and time', () {
      Set<ReminderFieldError> errors(ReminderDraft d) =>
          ReminderService.validate(d, now);

      expect(
        errors(ReminderDraft(target: ReminderTarget.session, remindAt: now)),
        {ReminderFieldError.titleRequired, ReminderFieldError.timeInPast},
      );
      expect(
        errors(
          ReminderDraft(
            target: ReminderTarget.task,
            remindAt: now.add(const Duration(hours: 1)),
          ),
        ),
        {ReminderFieldError.targetRequired},
      );
      expect(
        errors(
          ReminderDraft(
            target: ReminderTarget.session,
            title: 'Daily practice',
            remindAt: now.subtract(const Duration(days: 2)),
            repeat: ReminderRepeat.daily,
          ),
        ),
        isEmpty,
        reason: 'a repeating reminder may start in the past',
      );
    });

    test(
      'create drops seconds and moves a past repeating start ahead',
      () async {
        final created = await service.create(
          ReminderDraft(
            target: ReminderTarget.session,
            title: '  Daily   practice ',
            remindAt: DateTime(2026, 9, 28, 8, 15, 42),
            repeat: ReminderRepeat.daily,
          ),
        );
        expect(created.title, 'Daily practice');
        expect(created.remindAt, DateTime(2026, 10, 1, 8, 15));
        expect(await repository.getById(created.id), created);
      },
    );

    test('editing a finished reminder re-arms it', () async {
      final created = await service.create(
        ReminderDraft(
          target: ReminderTarget.session,
          title: 'Once',
          remindAt: now.add(const Duration(hours: 1)),
        ),
      );
      await repository.save(created.copyWith(lastFiredAt: now));

      final edited = await service.update(
        created.id,
        ReminderDraft(
          target: ReminderTarget.session,
          title: 'Once more',
          remindAt: now.add(const Duration(days: 1)),
        ),
      );
      expect(edited.lastFiredAt, isNull);
      expect(edited.isFinished, isFalse);
    });

    test('pause, resume and delete with restore', () async {
      final created = await service.create(
        ReminderDraft(
          target: ReminderTarget.session,
          title: 'x',
          remindAt: now.add(const Duration(hours: 1)),
        ),
      );
      expect(
        (await service.setEnabled(created.id, enabled: false)).isEnabled,
        isFalse,
      );
      expect(
        (await service.setEnabled(created.id, enabled: true)).isEnabled,
        isTrue,
      );

      final deleted = await service.delete(created.id);
      expect(await repository.getAll(), isEmpty);
      await service.restore(deleted);
      expect(await repository.getAll(), hasLength(1));
    });
  });
}
