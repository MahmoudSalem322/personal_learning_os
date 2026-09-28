import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/app/app.dart';
import 'package:personal_learning_os/app/bootstrap.dart';
import 'package:sembast/sembast_memory.dart';

/// Viewport sizes that land in each responsive layout.
abstract final class TestViewports {
  static const Size desktop = Size(1440, 900);
  static const Size tablet = Size(900, 1000);
  static const Size mobile = Size(390, 844);
}

extension PumpApp on WidgetTester {
  /// Bootstraps the real app on a fresh in-memory database and returns its
  /// provider container.
  Future<ProviderContainer> pumpLearningOs({
    Size size = TestViewports.desktop,
    DatabaseFactory? factory,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    final overrides = await runAsync(
      () => bootstrap(
        databaseFactory: factory ?? newDatabaseFactoryMemory(),
        isPersistent: true,
      ),
    );
    await pumpWidget(
      ProviderScope(overrides: overrides!, child: const LearningOsApp()),
    );
    await pumpAndSettle();
    return ProviderScope.containerOf(element(find.byType(LearningOsApp)));
  }
}
