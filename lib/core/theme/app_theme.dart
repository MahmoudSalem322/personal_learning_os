import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Material 3 [ThemeData] for each brightness from the design
/// tokens. Component themes are configured here once, so feature widgets can
/// use stock Material widgets and still look consistent.
abstract final class AppTheme {
  static final ThemeData light = _build(AppColors.light, Brightness.light);
  static final ThemeData dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = AppTypography.textTheme(text: c.text, muted: c.mutedText);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.secondarySoft,
      onSecondaryContainer: c.secondary,
      tertiary: c.info,
      onTertiary: c.onStatus,
      error: c.error,
      onError: c.onStatus,
      errorContainer: c.errorSoft,
      onErrorContainer: c.error,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.mutedText,
      surfaceDim: c.background,
      surfaceBright: c.surface,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surfaceMuted,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.borderStrong,
      outlineVariant: c.border,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.text,
      onInverseSurface: c.background,
      inversePrimary: c.primarySoft,
      surfaceTint: Colors.transparent,
    );

    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    );
    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.button);
    const buttonMinSize = Size(40, 40);

    WidgetStateProperty<Color?> overlay() =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return c.pressed;
          if (states.contains(WidgetState.hovered)) return c.hover;
          if (states.contains(WidgetState.focused)) return c.hover;
          return null;
        });

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      hoverColor: c.hover,
      focusColor: c.pressed,
      highlightColor: Colors.transparent,
      splashColor: c.pressed,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [c, AppShadows.from(c, brightness)],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
        shape: Border(bottom: BorderSide(color: c.border)),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.text,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: c.border),
          textStyle: textTheme.labelLarge,
        ).copyWith(overlayColor: overlay()),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.mutedText,
          minimumSize: buttonMinSize,
          shape: buttonShape,
        ).copyWith(overlayColor: overlay()),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          foregroundColor: c.mutedText,
          selectedForegroundColor: c.text,
          selectedBackgroundColor: c.surface,
          side: BorderSide(color: c.border),
          shape: buttonShape,
          textStyle: textTheme.labelMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surfaceMuted,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.mutedText),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.mutedText),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        selectedColor: c.primarySoft,
        side: BorderSide(color: c.border),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
          side: BorderSide(color: c.border),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.mutedText),
        barrierColor: c.scrim,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        scrimColor: c.scrim,
        shape: const RoundedRectangleBorder(),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        elevation: 6,
        shadowColor: c.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.menu,
          side: BorderSide(color: c.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          elevation: const WidgetStatePropertyAll(6),
          shadowColor: WidgetStatePropertyAll(c.shadow.withValues(alpha: 0.2)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: AppRadius.menu,
              side: BorderSide(color: c.border),
            ),
          ),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: MenuItemButton.styleFrom(
          foregroundColor: c.text,
          iconColor: c.mutedText,
          textStyle: textTheme.bodyMedium,
          minimumSize: const Size(180, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ).copyWith(overlayColor: overlay()),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: c.text,
          borderRadius: AppRadius.tooltip,
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: c.background),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.background),
        actionTextColor: c.primarySoft,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
        circularTrackColor: c.border,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(AppRadius.pill),
        thumbColor: WidgetStatePropertyAll(c.borderStrong),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.mutedText,
        textColor: c.text,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.navItem),
      ),
    );
  }
}
