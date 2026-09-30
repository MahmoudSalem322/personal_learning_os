import 'dart:convert';

import '../../../core/errors/app_exception.dart';
import '../../categories/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../notifications/domain/app_notification.dart';
import '../../reminders/domain/reminder.dart';
import '../../resources/domain/resource.dart';
import '../../settings/domain/app_settings.dart';
import '../../tasks/domain/task.dart';
import 'backup_snapshot.dart';

/// Why a backup file was rejected.
enum BackupProblem {
  /// Not valid JSON.
  notJson,

  /// JSON, but not a Qabas backup.
  notBackup,

  /// Made by a newer version of the app.
  newerVersion,

  /// Some records are malformed ([BackupFormatException.collection] and
  /// [BackupFormatException.count] say where and how many).
  invalidRecords,

  /// The same id appears twice in one collection.
  duplicateIds,
}

/// Thrown by [BackupCodec.decode]; nothing has been written when it is.
final class BackupFormatException extends AppException {
  BackupFormatException(this.problem, {this.collection, this.count = 0})
    : super(
        'Invalid backup: ${problem.name}'
        '${collection == null ? '' : ' in ${collection.name} ($count)'}',
      );

  final BackupProblem problem;
  final BackupCollection? collection;
  final int count;
}

/// Reads and writes backup files (JSON).
///
/// Format (version [format]):
/// ```json
/// {
///   "app": "learning-os", "format": 1, "exportedAt": "…",
///   "settings": {…},
///   "categories": [...], "resources": [...], "notes": [...],
///   "tasks": [...], "reminders": [...], "notifications": [...]
/// }
/// ```
/// Records use the same JSON as local storage. Missing collections are
/// read as empty, so older files still import.
abstract final class BackupCodec {
  /// Kept from the app's working name so older backups still import.
  static const String appId = 'learning-os';
  static const int format = 1;

  static const String _app = 'app';
  static const String _format = 'format';
  static const String _exportedAt = 'exportedAt';
  static const String _settings = 'settings';

  static String encode(BackupSnapshot snapshot, {required DateTime now}) {
    final json = <String, Object?>{
      _app: appId,
      _format: format,
      _exportedAt: now.toUtc().toIso8601String(),
      _settings: snapshot.settings.toJson(),
      BackupCollection.categories.name: [
        for (final c in snapshot.categories) c.toJson(),
      ],
      BackupCollection.resources.name: [
        for (final r in snapshot.resources) r.toJson(),
      ],
      BackupCollection.notes.name: [for (final n in snapshot.notes) n.toJson()],
      BackupCollection.tasks.name: [for (final t in snapshot.tasks) t.toJson()],
      BackupCollection.reminders.name: [
        for (final r in snapshot.reminders) r.toJson(),
      ],
      BackupCollection.notifications.name: [
        for (final n in snapshot.notifications) n.toJson(),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Parses and validates the whole file before returning anything.
  /// Throws [BackupFormatException] on the first problem found.
  static BackupSnapshot decode(String text) {
    final Object? root;
    try {
      root = jsonDecode(text);
    } on FormatException {
      throw BackupFormatException(BackupProblem.notJson);
    }
    if (root is! Map<String, Object?> || root[_app] != appId) {
      throw BackupFormatException(BackupProblem.notBackup);
    }
    final Map<String, Object?> file = root;
    final version = file[_format];
    if (version is! int || version < 1) {
      throw BackupFormatException(BackupProblem.notBackup);
    }
    if (version > format) {
      throw BackupFormatException(BackupProblem.newerVersion);
    }

    List<T> read<T>(
      BackupCollection collection,
      T Function(Map<String, Object?>) fromJson,
      String Function(T) idOf,
    ) {
      final raw = file[collection.name];
      if (raw == null) return const [];
      if (raw is! List) {
        throw BackupFormatException(BackupProblem.notBackup);
      }
      final items = <T>[];
      var invalid = 0;
      for (final entry in raw) {
        try {
          final item = fromJson(Map<String, Object?>.from(entry as Map));
          if (idOf(item).isEmpty) throw const FormatException('empty id');
          items.add(item);
        } catch (_) {
          invalid++;
        }
      }
      if (invalid > 0) {
        throw BackupFormatException(
          BackupProblem.invalidRecords,
          collection: collection,
          count: invalid,
        );
      }
      final ids = {for (final item in items) idOf(item)};
      if (ids.length != items.length) {
        throw BackupFormatException(
          BackupProblem.duplicateIds,
          collection: collection,
          count: items.length - ids.length,
        );
      }
      return items;
    }

    final rawSettings = file[_settings];
    final exportedAt = file[_exportedAt];
    return BackupSnapshot(
      settings: rawSettings is Map
          ? AppSettings.fromJson(Map<String, Object?>.from(rawSettings))
          : AppSettings.defaults,
      categories: read(
        BackupCollection.categories,
        Category.fromJson,
        (c) => c.id,
      ),
      resources: read(
        BackupCollection.resources,
        Resource.fromJson,
        (r) => r.id,
      ),
      notes: read(BackupCollection.notes, Note.fromJson, (n) => n.id),
      tasks: read(BackupCollection.tasks, Task.fromJson, (t) => t.id),
      reminders: read(
        BackupCollection.reminders,
        Reminder.fromJson,
        (r) => r.id,
      ),
      notifications: read(
        BackupCollection.notifications,
        AppNotification.fromJson,
        (n) => n.id,
      ),
      exportedAt: exportedAt is String ? DateTime.tryParse(exportedAt) : null,
    ).withValidLinks();
  }
}
