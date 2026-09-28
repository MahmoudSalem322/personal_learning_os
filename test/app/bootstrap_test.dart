import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/app/bootstrap.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/core/storage/storage_providers.dart';
import 'package:personal_learning_os/features/settings/data/local_settings_repository.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';
import 'package:sembast/sembast_memory.dart';

/// A factory whose storage is unavailable, like IndexedDB in some private
/// browsing modes.
class _BrokenDatabaseFactory implements DatabaseFactory {
  @override
  Future<Database> openDatabase(
    String path, {
    int? version,
    OnVersionChangedFunction? onVersionChanged,
    DatabaseMode? mode,
    SembastCodec? codec,
  }) => Future.error(StateError('IndexedDB blocked'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  ProviderContainer containerFor(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  test('opens persistent storage and reads stored settings', () async {
    final factory = newDatabaseFactoryMemory();
    final db = await AppDatabase.open(factory);
    const stored = AppSettings(
      themePreference: ThemePreference.dark,
      language: AppLanguage.arabic,
    );
    await LocalSettingsRepository(db).save(stored);
    await db.close();

    final container = containerFor(
      await bootstrap(databaseFactory: factory, isPersistent: true),
    );

    expect(container.read(storageStatusProvider), StorageStatus.persistent);
    expect(container.read(settingsControllerProvider), stored);
  });

  test('falls back to in-memory storage when persistence fails', () async {
    final container = containerFor(
      await bootstrap(databaseFactory: _BrokenDatabaseFactory()),
    );

    expect(container.read(storageStatusProvider), StorageStatus.volatile);
    expect(container.read(settingsControllerProvider), AppSettings.defaults);

    // The app remains usable on the fallback database.
    await container
        .read(settingsControllerProvider.notifier)
        .setThemePreference(ThemePreference.light);
    expect(
      await container.read(settingsRepositoryProvider).load(),
      const AppSettings(themePreference: ThemePreference.light),
    );
  });
}
