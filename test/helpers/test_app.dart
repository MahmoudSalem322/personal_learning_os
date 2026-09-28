import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/app.dart';
import 'package:personal_learning_os/app/bootstrap.dart';
import 'package:personal_learning_os/core/services/url_opener.dart';
import 'package:sembast/sembast_memory.dart'
    show DatabaseFactory, newDatabaseFactoryMemory;

/// Viewport sizes that land in each responsive layout.
abstract final class TestViewports {
  static const Size desktop = Size(1440, 900);
  static const Size tablet = Size(900, 1000);
  static const Size mobile = Size(390, 844);
}

/// Finds a material_ui [Tooltip] by message.
///
/// `find.byTooltip` only knows the framework's own Tooltip class, so it
/// misses material_ui tooltips that set `excludeFromSemantics` (used where
/// the control already has a semantic label).
Finder findTooltip(String message) => find.byWidgetPredicate(
  (widget) => widget is Tooltip && widget.message == message,
  description: 'Tooltip "$message"',
);

/// Records links instead of opening browser tabs.
class FakeUrlOpener implements UrlOpener {
  final List<String> opened = [];

  /// Simulates a pop-up blocker when false.
  bool allow = true;

  @override
  bool openInNewTab(String url) {
    if (allow) opened.add(url);
    return allow;
  }
}

extension PumpApp on WidgetTester {
  /// Bootstraps the real app on a fresh in-memory database and returns its
  /// provider container.
  Future<ProviderContainer> pumpLearningOs({
    Size size = TestViewports.desktop,
    DatabaseFactory? factory,
    UrlOpener? urlOpener,
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
      ProviderScope(
        overrides: [
          ...overrides!,
          urlOpenerProvider.overrideWithValue(urlOpener ?? FakeUrlOpener()),
        ],
        child: const LearningOsApp(),
      ),
    );
    await pumpAndSettle();
    return ProviderScope.containerOf(element(find.byType(LearningOsApp)));
  }

  /// Runs real storage work (sembast) outside the fake-async test zone,
  /// then lets the resulting stream updates reach the widgets.
  ///
  /// sembast delivers change notifications on the real event loop, so we
  /// yield to it a few times, pumping in between.
  Future<T> io<T>(Future<T> Function() body) async {
    final result = await runAsync(body);
    for (var i = 0; i < 5; i++) {
      await runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await pump();
    }
    await pumpAndSettle();
    return result as T;
  }

  /// Taps [finder], then waits for any storage work it triggered.
  Future<void> tapAndSettleIo(Finder finder) async {
    await tap(finder);
    await io(() => Future<void>.delayed(Duration.zero));
  }
}
