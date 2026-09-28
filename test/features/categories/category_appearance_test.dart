import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/core/theme/accent_visual.dart';
import 'package:personal_learning_os/core/theme/app_colors.dart';
import 'package:personal_learning_os/features/categories/presentation/category_appearance.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('AccentVisual', () {
    for (final (brightness, colors) in [
      (Brightness.light, AppColors.light),
      (Brightness.dark, AppColors.dark),
    ]) {
      test('icons stay legible on every preset in ${brightness.name} mode', () {
        for (final preset in CategoryColors.all) {
          final visual = AccentVisual.resolve(
            primaryColor: preset.primary.toARGB32(),
            secondaryColor: preset.secondary.toARGB32(),
            brightness: brightness,
            surface: colors.card,
          );
          final tile = Color.alphaBlend(visual.tint, colors.card);
          // WCAG 1.4.11: non-text UI graphics need at least 3:1.
          expect(
            _contrast(visual.foreground, tile),
            greaterThanOrEqualTo(3),
            reason: '${preset.key} in ${brightness.name}',
          );
        }
      });
    }
  });

  test('icon keys are unique and unknown keys fall back to the folder', () {
    final keys = CategoryIcons.all.map((o) => o.key).toList();
    expect(keys.toSet(), hasLength(keys.length));
    expect(CategoryIcons.resolve('does-not-exist'), Icons.folder_rounded);
    expect(CategoryIcons.resolve('code'), Icons.code_rounded);
  });

  test('suggest picks the first unused color', () {
    final blue = CategoryColors.byKey('blue').primary.toARGB32();
    final indigo = CategoryColors.byKey('indigo').primary.toARGB32();
    expect(CategoryColors.suggest(const []).key, 'blue');
    expect(CategoryColors.suggest([blue]).key, 'indigo');
    expect(CategoryColors.suggest([blue, indigo]).key, 'purple');
  });
}
