import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/core/storage/app_database.dart';
import 'package:personal_learning_os/features/settings/data/local_settings_repository.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late DatabaseFactory factory;
  late Database db;
  late LocalSettingsRepository repository;

  setUp(() async {
    factory = newDatabaseFactoryMemory();
    db = await AppDatabase.open(factory);
    repository = LocalSettingsRepository(db);
  });

  tearDown(() => db.close());

  test('returns defaults when nothing is stored', () async {
    expect(await repository.load(), AppSettings.defaults);
  });

  test('saves and loads settings', () async {
    const settings = AppSettings(
      themePreference: ThemePreference.dark,
      language: AppLanguage.english,
    );
    await repository.save(settings);
    expect(await repository.load(), settings);
  });

  test('settings survive closing and reopening the database', () async {
    const settings = AppSettings(language: AppLanguage.arabic);
    await repository.save(settings);
    await db.close();

    db = await AppDatabase.open(factory);
    expect(await LocalSettingsRepository(db).load(), settings);
  });

  test('tolerates stored data with unknown values', () async {
    await AppStores.settings.record('app').put(db, {
      'themePreference': 'sepia',
      'language': 'arabic',
    });
    final loaded = await repository.load();
    expect(loaded.themePreference, ThemePreference.system);
    expect(loaded.language, AppLanguage.arabic);
  });

  test('wraps storage failures in StorageException', () async {
    await db.close();
    expect(
      () => repository.save(AppSettings.defaults),
      throwsA(isA<StorageException>()),
    );
  });
}
