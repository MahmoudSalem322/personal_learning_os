import 'package:material_ui/material_ui.dart';

/// Type scale of the design system.
///
/// Styles are exposed through the Material [TextTheme] so built-in components
/// pick them up, and through the semantic getters in [AppTextStyles]
/// (`context.textStyles.heading`, ...).
abstract final class AppTypography {
  /// Single place to switch the app font. `null` uses the platform default.
  static const String? fontFamily = null;

  static TextTheme textTheme({required Color text, required Color muted}) {
    TextStyle style(
      double size,
      double lineHeight,
      FontWeight weight, {
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? text,
      );
    }

    return TextTheme(
      displayLarge: style(48, 56, FontWeight.w700, letterSpacing: -1),
      displayMedium: style(40, 48, FontWeight.w700, letterSpacing: -0.8),
      displaySmall: style(32, 40, FontWeight.w700, letterSpacing: -0.6),
      headlineLarge: style(28, 36, FontWeight.w600, letterSpacing: -0.4),
      headlineMedium: style(24, 32, FontWeight.w600, letterSpacing: -0.3),
      headlineSmall: style(20, 28, FontWeight.w600, letterSpacing: -0.2),
      titleLarge: style(18, 26, FontWeight.w600),
      titleMedium: style(16, 24, FontWeight.w600),
      titleSmall: style(14, 20, FontWeight.w600),
      bodyLarge: style(16, 24, FontWeight.w400),
      bodyMedium: style(14, 22, FontWeight.w400),
      bodySmall: style(12, 16, FontWeight.w400, color: muted),
      labelLarge: style(14, 20, FontWeight.w500),
      labelMedium: style(13, 18, FontWeight.w500),
      labelSmall: style(
        11,
        16,
        FontWeight.w600,
        letterSpacing: 0.4,
        color: muted,
      ),
    );
  }

  /// Arabic is a connected script and any tracking breaks the joins between
  /// letters, so letter spacing is reset for it.
  static TextTheme forLocale(TextTheme theme, Locale locale) {
    if (locale.languageCode != 'ar') return theme;
    TextStyle? reset(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return theme.copyWith(
      displayLarge: reset(theme.displayLarge),
      displayMedium: reset(theme.displayMedium),
      displaySmall: reset(theme.displaySmall),
      headlineLarge: reset(theme.headlineLarge),
      headlineMedium: reset(theme.headlineMedium),
      headlineSmall: reset(theme.headlineSmall),
      labelSmall: reset(theme.labelSmall),
    );
  }
}

/// Semantic names for the type scale.
extension AppTextStyles on TextTheme {
  /// Hero numbers and display text.
  TextStyle get display => displaySmall!;

  /// Page titles.
  TextStyle get heading => headlineMedium!;

  /// Section headings.
  TextStyle get subheading => headlineSmall!;

  /// Card and list item titles.
  TextStyle get title => titleMedium!;

  TextStyle get body => bodyMedium!;

  TextStyle get bodyStrong => bodyMedium!.copyWith(fontWeight: FontWeight.w500);

  /// Secondary metadata such as dates and counts.
  TextStyle get caption => bodySmall!;

  /// Buttons, chips and navigation.
  TextStyle get label => labelMedium!;

  /// Small section labels.
  TextStyle get overline => labelSmall!;
}
