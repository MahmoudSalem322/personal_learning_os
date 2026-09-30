// Generates every app icon from the brand mark painter.
//
//   flutter test tool/generate_icons_test.dart
//
// Lives outside test/ so it doesn't run with the normal suite. Rerun after
// changing `QabasMarkPainter` (lib/core/widgets/app_logo.dart).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/core/widgets/app_logo.dart';

/// Safe zones: Android adaptive icons keep a 66/108 circle, maskable web
/// icons an 80% circle. The spark reaches ~26% from the center.
const double _adaptiveScale = 0.9;
const double _maskableScale = 1.0;

Future<void> _render(
  WidgetTester tester,
  QabasMarkPainter painter,
  int pixels,
  String path,
) async {
  const logical = 256.0;
  final key = GlobalKey();
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        key: key,
        child: SizedBox.square(
          dimension: logical,
          child: CustomPaint(painter: painter),
        ),
      ),
    ),
  );
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixels / logical);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

void main() {
  const res = 'android/app/src/main/res';
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };

  testWidgets('brand artwork', (tester) async {
    await _render(
      tester,
      const QabasMarkPainter(),
      1024,
      'branding/qabas-icon-1024.png',
    );
  });

  testWidgets('web icons', (tester) async {
    await _render(tester, const QabasMarkPainter(), 32, 'web/favicon.png');
    for (final size in [192, 512]) {
      await _render(
        tester,
        const QabasMarkPainter(),
        size,
        'web/icons/Icon-$size.png',
      );
      await _render(
        tester,
        const QabasMarkPainter(
          fullBleed: true,
          contentScale: _maskableScale,
        ),
        size,
        'web/icons/Icon-maskable-$size.png',
      );
    }
  });

  testWidgets('android icons', (tester) async {
    for (final MapEntry(key: density, value: scale) in densities.entries) {
      final dir = '$res/mipmap-$density';
      // Legacy launchers (Android 7 and older).
      await _render(
        tester,
        const QabasMarkPainter(margin: 0.04),
        (48 * scale).round(),
        '$dir/ic_launcher.png',
      );
      // Adaptive icon layers (108 dp); the background is a gradient
      // drawable (drawable/ic_launcher_background.xml).
      await _render(
        tester,
        const QabasMarkPainter(
          background: false,
          contentScale: _adaptiveScale,
        ),
        (108 * scale).round(),
        '$dir/ic_launcher_foreground.png',
      );
      await _render(
        tester,
        const QabasMarkPainter(
          background: false,
          monochrome: true,
          contentScale: _adaptiveScale,
        ),
        (108 * scale).round(),
        '$dir/ic_launcher_monochrome.png',
      );
    }
  });
}
