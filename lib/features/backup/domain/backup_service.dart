import 'backup_codec.dart';
import 'backup_snapshot.dart';
import 'backup_store.dart';

/// How an imported backup meets the data already here.
enum ImportMode {
  /// Keep current data; add new records and take newer versions.
  merge,

  /// Discard current data and settings; use the backup's.
  replace,
}

/// Export, import and clear. Every destructive operation returns the state
/// before it, so the caller can offer Undo.
class BackupService {
  BackupService(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final BackupStore _store;
  final DateTime Function() _clock;

  /// Everything, as backup file contents.
  Future<String> exportJson() async =>
      BackupCodec.encode(await _store.read(), now: _clock());

  /// e.g. `qabas-backup-2026-09-30.json`.
  String fileName() {
    final now = _clock();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'qabas-backup-${now.year}-${two(now.month)}-${two(now.day)}'
        '.json';
  }

  /// Validates a file's contents. Throws `BackupFormatException`.
  BackupSnapshot parse(String text) => BackupCodec.decode(text);

  /// Applies [incoming] and returns what was there before.
  Future<BackupSnapshot> import(
    BackupSnapshot incoming,
    ImportMode mode,
  ) async {
    final previous = await _store.read();
    final next = switch (mode) {
      ImportMode.merge => previous.mergedWith(incoming),
      ImportMode.replace => incoming.withValidLinks(),
    };
    await _store.replaceAll(next);
    return previous;
  }

  /// Deletes all data but keeps the settings; returns what was there.
  Future<BackupSnapshot> clearAll() async {
    final previous = await _store.read();
    await _store.replaceAll(BackupSnapshot(settings: previous.settings));
    return previous;
  }

  /// Puts back a state returned by [import] or [clearAll] (Undo).
  Future<void> restore(BackupSnapshot previous) => _store.replaceAll(previous);
}
