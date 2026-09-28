import 'app_settings.dart';

/// Persists [AppSettings].
///
/// Implementations throw `StorageException` on failure. The interface is
/// storage-agnostic, so a cloud-synced implementation can replace the local
/// one without touching the presentation layer.
abstract interface class SettingsRepository {
  /// Returns the stored settings, or [AppSettings.defaults] when none exist.
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}
