import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Elevation tokens. Access them with `context.shadows`.
///
/// Shadows are intentionally soft: the design relies on borders and
/// background contrast first, and uses shadows only to lift floating layers.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({required this.sm, required this.md, required this.lg});

  factory AppShadows.from(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    Color tint(double lightAlpha, double darkAlpha) =>
        colors.shadow.withValues(alpha: isDark ? darkAlpha : lightAlpha);
    return AppShadows(
      sm: [
        BoxShadow(
          color: tint(0.04, 0.30),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: tint(0.04, 0.30),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: tint(0.07, 0.40),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      lg: [
        BoxShadow(
          color: tint(0.05, 0.35),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: tint(0.12, 0.55),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  /// Resting cards and small raised controls.
  final List<BoxShadow> sm;

  /// Hovered cards and popovers.
  final List<BoxShadow> md;

  /// Dialogs, drawers and command palettes.
  final List<BoxShadow> lg;

  @override
  AppShadows copyWith({
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
  }) {
    return AppShadows(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);
  }

  @override
  AppShadows lerp(covariant AppShadows? other, double t) {
    if (other == null) return this;
    return AppShadows(
      sm: BoxShadow.lerpList(sm, other.sm, t)!,
      md: BoxShadow.lerpList(md, other.md, t)!,
      lg: BoxShadow.lerpList(lg, other.lg, t)!,
    );
  }
}
