import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Colors for rendering an accent-colored element (category, resource type)
/// in the current brightness.
///
/// Stored colors are mid-tones. The icon color keeps the hue but its
/// lightness is shifted (darker on light surfaces, lighter on dark ones)
/// until it reaches [minContrast] against the tile, so any color, including
/// bright yellows, stays legible in both themes.
@immutable
class AccentVisual {
  const AccentVisual._({
    required this.foreground,
    required this.gradient,
    required this.tint,
  });

  factory AccentVisual.resolve({
    required int primaryColor,
    required int secondaryColor,
    required Brightness brightness,
    required Color surface,
  }) {
    final isDark = brightness == Brightness.dark;
    final primary = Color(primaryColor);
    final secondary = Color(secondaryColor);
    final alpha = isDark ? 0.22 : 0.14;
    final tint = primary.withValues(alpha: alpha);
    final tile = Color.alphaBlend(tint, surface);

    final hsl = HSLColor.fromColor(primary);
    var lightness = isDark
        ? hsl.lightness.clamp(0.70, 1.0)
        : hsl.lightness.clamp(0.0, 0.45);
    var foreground = hsl.withLightness(lightness).toColor();
    while (_contrast(foreground, tile) < minContrast &&
        lightness > 0.05 &&
        lightness < 0.95) {
      lightness += isDark ? 0.03 : -0.03;
      foreground = hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    }

    return AccentVisual._(
      foreground: foreground,
      tint: tint,
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          primary.withValues(alpha: alpha),
          secondary.withValues(alpha: alpha * 0.7),
        ],
      ),
    );
  }

  /// Icon and accent text color.
  final Color foreground;

  /// Soft background of the icon tile.
  final Gradient gradient;

  /// Flat version of the tile background (used for contrast checks).
  final Color tint;

  /// Icons are UI graphics; WCAG 1.4.11 asks for 3:1. A small margin keeps
  /// the gradient's lighter corner above it too.
  static const double minContrast = 3.5;

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }
}
