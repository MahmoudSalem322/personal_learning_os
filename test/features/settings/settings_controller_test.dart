import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/errors/app_exception.dart';
import 'package:personal_learning_os/features/settings/domain/app_settings.dart';
import 'package:personal_learning_os/features/settings/domain/settings_repository.dart';
import 'package:personal_learning_os/features/settings/presentation/settings_controller.dart';

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings? saved;
  bool failOnSave = false;

  @override
  Future<AppSettings> load() async => saved ?? AppSettings.defaults;

  @override
  Future<void> save(AppSettings settings) async {
    if (failOnSave) throw const StorageException('disk full');
    saved = settings;
  }
}

void main() {
  late _FakeSettingsRepository repository;
  late ProviderContainer container;

  ProviderContainer createContainer({AppSettings? initial}) {
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repository),
        if (initial != null) initialSettingsProvider.overrideWithValue(initial),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    repository = _FakeSettingsRepository();
    container = createContainer();
  });

  test('starts from the settings loaded at bootstrap', () {
    const initial = AppSettings(themePreference: ThemePreference.dark);
    final container = createContainer(initial: initial);
    expect(container.read(settingsControllerProvider), initial);
  });

  test('updates state and persists the theme preference', () async {
    await container
        .read(settingsControllerProvider.notifier)
        .setThemePreference(ThemePreference.light);

    expect(
      container.read(settingsControllerProvider).themePreference,
      ThemePreference.light,
    );
    expect(repository.saved?.themePreference, ThemePreference.light);
  });

  test('updates state and persists the language', () async {
    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.arabic);

    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.arabic,
    );
    expect(repository.saved?.language, AppLanguage.arabic);
  });

  test('skips saving when the value does not change', () async {
    await container
        .read(settingsControllerProvider.notifier)
        .setThemePreference(ThemePreference.system);
    expect(repository.saved, isNull);
  });

  test('rolls back and rethrows when saving fails', () async {
    repository.failOnSave = true;
    final controller = container.read(settingsControllerProvider.notifier);

    await expectLater(
      controller.setThemePreference(ThemePreference.dark),
      throwsA(isA<StorageException>()),
    );
    expect(container.read(settingsControllerProvider), AppSettings.defaults);
  });
}
