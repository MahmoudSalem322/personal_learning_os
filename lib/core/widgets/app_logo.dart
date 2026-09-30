import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';

/// The Qabas (قبس, "a spark of light") brand mark: one white spark on a
/// navy tile.
///
/// The same painter draws the in-app logo and every app icon
/// (`tool/generate_icons_test.dart`), so they always match.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: QabasMarkPainter()),
      ),
    );
  }
}

/// Paints the brand mark into a square canvas.
///
/// - [background]: `true` draws the navy tile; `false` leaves it
///   transparent (Android adaptive-icon foreground).
/// - [fullBleed]: fills the whole square instead of a rounded tile
///   (maskable web icons; the platform applies its own mask).
/// - [contentScale]: shrinks the spark to fit a platform's safe zone.
/// - [monochrome]: flat white spark only (Android themed icons).
/// - [margin]: empty border around the tile, as a fraction of the size.
class QabasMarkPainter extends CustomPainter {
  const QabasMarkPainter({
    this.background = true,
    this.fullBleed = false,
    this.contentScale = 1,
    this.monochrome = false,
    this.margin = 0,
  });

  final bool background;
  final bool fullBleed;
  final double contentScale;
  final bool monochrome;
  final double margin;

  /// Design grid: the mark is drawn in a 1024 × 1024 box.
  static const double _grid = 1024;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / _grid);

    final inset = margin * _grid;
    final tile = Rect.fromLTWH(
      inset,
      inset,
      _grid - 2 * inset,
      _grid - 2 * inset,
    );
    if (background && !monochrome) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          tile,
          Radius.circular(fullBleed ? 0 : tile.width * 0.225),
        ),
        Paint()..color = AppPalette.logoNavy,
      );
    }

    // A four-point spark with softly curved sides.
    final scale = contentScale * tile.width / _grid;
    const c = Offset(_grid / 2, _grid / 2);
    final tall = 268 * scale;
    final wide = 210 * scale;
    final pinch = 30 * scale;
    canvas
      ..drawPath(
        Path()
          ..moveTo(c.dx, c.dy - tall)
          ..quadraticBezierTo(c.dx + pinch, c.dy - pinch, c.dx + wide, c.dy)
          ..quadraticBezierTo(c.dx + pinch, c.dy + pinch, c.dx, c.dy + tall)
          ..quadraticBezierTo(c.dx - pinch, c.dy + pinch, c.dx - wide, c.dy)
          ..quadraticBezierTo(c.dx - pinch, c.dy - pinch, c.dx, c.dy - tall)
          ..close(),
        Paint()..color = AppPalette.logoMark,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(QabasMarkPainter old) =>
      old.background != background ||
      old.fullBleed != fullBleed ||
      old.contentScale != contentScale ||
      old.monochrome != monochrome ||
      old.margin != margin;
}
