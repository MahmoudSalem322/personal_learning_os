import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/local_reminder_repository.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';
import '../domain/reminder_service.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => LocalReminderRepository(ref.watch(appDatabaseProvider)),
);

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(ref.watch(reminderRepositoryProvider)),
);

/// All reminders, soonest first; updates live.
final remindersProvider = StreamProvider<List<Reminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAll(),
);

/// Reminders of one task or resource, soonest first.
final remindersForProvider =
    Provider.family<List<Reminder>, (ReminderTarget, String)>((ref, item) {
      final (target, id) = item;
      final all = ref.watch(remindersProvider).value ?? const [];
      return [
        for (final r in all)
          if (r.target == target && r.targetId == id) r,
      ];
    });
