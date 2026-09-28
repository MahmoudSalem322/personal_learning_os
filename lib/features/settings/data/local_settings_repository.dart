import 'package:sembast/sembast.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/app_database.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// [SettingsRepository] backed by the local sembast database.
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._db);

  final Database _db;

  static const String _recordKey = 'app';

  RecordRef<String, Map<String, Object?>> get _record =>
      AppStores.settings.record(_recordKey);

  @override
  Future<AppSettings> load() async {
    try {
      final json = await _record.get(_db);
      return json == null ? AppSettings.defaults : AppSettings.fromJson(json);
    } catch (error, stackTrace) {
      throw StorageException(
        'Failed to load settings',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      await _record.put(_db, settings.toJson());
    } catch (error, stackTrace) {
      throw StorageException(
        'Failed to save settings',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
