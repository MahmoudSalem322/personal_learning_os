import 'package:material_ui/material_ui.dart';

import 'app_palette.dart';

/// Semantic color tokens of the design system.
///
/// Access them with `context.colors`. Every token has a light and a dark
/// value, so widgets never need to branch on brightness themselves.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.secondarySoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.card,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.mutedText,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.info,
    required this.infoSoft,
    required this.onStatus,
    required this.hover,
    required this.pressed,
    required this.focusRing,
    required this.shadow,
    required this.scrim,
  });

  /// Brand accent for primary actions, selection and focus.
  final Color primary;
  final Color onPrimary;

  /// Low-emphasis tint of [primary] for selected rows, badges and icons.
  final Color primarySoft;

  final Color secondary;
  final Color onSecondary;
  final Color secondarySoft;

  /// App canvas behind all content.
  final Color background;

  /// Raised planes such as dialogs, menus and the sidebar.
  final Color surface;

  /// Recessed or subtle planes such as inputs and grouped sections.
  final Color surfaceMuted;

  final Color card;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color mutedText;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;
  final Color info;
  final Color infoSoft;

  /// Foreground on solid status colors.
  final Color onStatus;

  /// Overlay for hovered interactive elements.
  final Color hover;

  /// Overlay for pressed interactive elements.
  final Color pressed;

  final Color focusRing;
  final Color shadow;
  final Color scrim;

  static const AppColors light = AppColors(
    primary: AppPalette.indigo600,
    onPrimary: AppPalette.neutral0,
    primarySoft: AppPalette.indigo50,
    secondary: AppPalette.teal600,
    onSecondary: AppPalette.neutral0,
    secondarySoft: AppPalette.teal50,
    background: AppPalette.neutral25,
    surface: AppPalette.neutral0,
    surfaceMuted: AppPalette.neutral50,
    card: AppPalette.neutral0,
    border: AppPalette.neutral200,
    borderStrong: AppPalette.neutral300,
    text: AppPalette.neutral900,
    mutedText: AppPalette.neutral500,
    success: AppPalette.green600,
    successSoft: AppPalette.green50,
    warning: AppPalette.amber600,
    warningSoft: AppPalette.amber50,
    error: AppPalette.red600,
    errorSoft: AppPalette.red50,
    info: AppPalette.blue600,
    infoSoft: AppPalette.blue50,
    onStatus: AppPalette.neutral0,
    hover: AppPalette.lightHover,
    pressed: AppPalette.lightPressed,
    focusRing: AppPalette.lightFocus,
    shadow: AppPalette.black,
    scrim: AppPalette.lightScrim,
  );

  static const AppColors dark = AppColors(
    primary: AppPalette.indigo400,
    onPrimary: AppPalette.ink950,
    primarySoft: AppPalette.indigo950,
    secondary: AppPalette.teal400,
    onSecondary: AppPalette.ink950,
    secondarySoft: AppPalette.teal950,
    background: AppPalette.ink950,
    surface: AppPalette.ink900,
    surfaceMuted: AppPalette.ink850,
    card: AppPalette.ink850,
    border: AppPalette.ink700,
    borderStrong: AppPalette.ink600,
    text: AppPalette.ink50,
    mutedText: AppPalette.ink300,
    success: AppPalette.green400,
    successSoft: AppPalette.green950,
    warning: AppPalette.amber400,
    warningSoft: AppPalette.amber950,
    error: AppPalette.red400,
    errorSoft: AppPalette.red950,
    info: AppPalette.blue400,
    infoSoft: AppPalette.blue950,
    onStatus: AppPalette.ink950,
    hover: AppPalette.darkHover,
    pressed: AppPalette.darkPressed,
    focusRing: AppPalette.darkFocus,
    shadow: AppPalette.black,
    scrim: AppPalette.darkScrim,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? secondary,
    Color? onSecondary,
    Color? secondarySoft,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? card,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? mutedText,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? error,
    Color? errorSoft,
    Color? info,
    Color? infoSoft,
    Color? onStatus,
    Color? hover,
    Color? pressed,
    Color? focusRing,
    Color? shadow,
    Color? scrim,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      card: card ?? this.card,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      onStatus: onStatus ?? this.onStatus,
      hover: hover ?? this.hover,
      pressed: pressed ?? this.pressed,
      focusRing: focusRing ?? this.focusRing,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      secondary: l(secondary, other.secondary),
      onSecondary: l(onSecondary, other.onSecondary),
      secondarySoft: l(secondarySoft, other.secondarySoft),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      card: l(card, other.card),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      mutedText: l(mutedText, other.mutedText),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      error: l(error, other.error),
      errorSoft: l(errorSoft, other.errorSoft),
      info: l(info, other.info),
      infoSoft: l(infoSoft, other.infoSoft),
      onStatus: l(onStatus, other.onStatus),
      hover: l(hover, other.hover),
      pressed: l(pressed, other.pressed),
      focusRing: l(focusRing, other.focusRing),
      shadow: l(shadow, other.shadow),
      scrim: l(scrim, other.scrim),
    );
  }
}
