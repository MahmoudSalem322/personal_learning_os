import 'package:flutter/widgets.dart';

/// Spacing scale. Use these values for padding, margins and gaps instead of
/// arbitrary numbers.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Fixed-size gaps built on [AppSpacing], for use inside rows and columns.
abstract final class Gap {
  static const SizedBox xxs = SizedBox.square(dimension: AppSpacing.xxs);
  static const SizedBox xs = SizedBox.square(dimension: AppSpacing.xs);
  static const SizedBox sm = SizedBox.square(dimension: AppSpacing.sm);
  static const SizedBox md = SizedBox.square(dimension: AppSpacing.md);
  static const SizedBox lg = SizedBox.square(dimension: AppSpacing.lg);
  static const SizedBox xl = SizedBox.square(dimension: AppSpacing.xl);
  static const SizedBox xxl = SizedBox.square(dimension: AppSpacing.xxl);
}
