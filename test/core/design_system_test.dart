import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/core/theme/app_colors.dart';
import 'package:personal_learning_os/core/theme/app_shadows.dart';
import 'package:personal_learning_os/core/theme/app_theme.dart';
import 'package:personal_learning_os/core/utils/screen_size.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('themes', () {
    for (final (name, theme, brightness) in [
      ('light', AppTheme.light, Brightness.light),
      ('dark', AppTheme.dark, Brightness.dark),
    ]) {
      test('$name theme registers design tokens', () {
        expect(theme.brightness, brightness);
        expect(theme.useMaterial3, isTrue);
        expect(theme.extension<AppColors>(), isNotNull);
        expect(theme.extension<AppShadows>(), isNotNull);
      });

      test('$name text colors meet WCAG AA contrast', () {
        final c = theme.extension<AppColors>()!;
        for (final surface in [c.background, c.surface, c.card]) {
          expect(_contrast(c.text, surface), greaterThanOrEqualTo(4.5));
          expect(_contrast(c.mutedText, surface), greaterThanOrEqualTo(4.5));
        }
        expect(_contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.primary, c.primarySoft), greaterThanOrEqualTo(4.5));
      });
    }
  });

  test('AppColors.lerp interpolates between modes', () {
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(mid.background, isNot(AppColors.light.background));
    expect(AppColors.light.lerp(AppColors.dark, 0).text, AppColors.light.text);
    expect(AppColors.light.lerp(AppColors.dark, 1).text, AppColors.dark.text);
  });

  group('ScreenSize.fromWidth', () {
    test('maps widths to layouts', () {
      expect(ScreenSize.fromWidth(375), ScreenSize.mobile);
      expect(ScreenSize.fromWidth(639), ScreenSize.mobile);
      expect(ScreenSize.fromWidth(640), ScreenSize.tablet);
      expect(ScreenSize.fromWidth(1099), ScreenSize.tablet);
      expect(ScreenSize.fromWidth(1100), ScreenSize.desktop);
      expect(ScreenSize.fromWidth(1920), ScreenSize.desktop);
    });
  });
}
