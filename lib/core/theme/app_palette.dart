import 'package:flutter/widgets.dart';

/// Raw color values of the design system.
///
/// This is the only file in the app allowed to contain hex color literals.
/// Widgets never read from here directly; they use the semantic tokens in
/// `AppColors` (via `context.colors`) so light and dark modes stay in sync.
abstract final class AppPalette {
  // Brand
  static const Color indigo400 = Color(0xFF8B89F2);
  static const Color indigo600 = Color(0xFF5B57DB);
  static const Color indigo50 = Color(0xFFF0F0FD);
  static const Color indigo950 = Color(0xFF232248);

  static const Color teal400 = Color(0xFF2DC4B2);
  // Tuned so text on teal50 and white passes WCAG AA (4.7:1+).
  static const Color teal600 = Color(0xFF0B7A70);
  static const Color teal50 = Color(0xFFE8F7F5);
  static const Color teal950 = Color(0xFF0F2E2B);

  // Neutrals (light)
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral25 = Color(0xFFFAFAFB);
  static const Color neutral50 = Color(0xFFF4F4F6);
  static const Color neutral200 = Color(0xFFE4E4E8);
  static const Color neutral300 = Color(0xFFD1D1D7);
  static const Color neutral500 = Color(0xFF6B6B75);
  static const Color neutral900 = Color(0xFF18181C);

  // Neutrals (dark)
  static const Color ink950 = Color(0xFF0D0D10);
  static const Color ink900 = Color(0xFF131317);
  static const Color ink850 = Color(0xFF18181D);
  static const Color ink700 = Color(0xFF27272F);
  static const Color ink600 = Color(0xFF35353F);
  static const Color ink300 = Color(0xFFA3A3AE);
  static const Color ink50 = Color(0xFFEDEDF0);

  // Status (light)
  static const Color green600 = Color(0xFF15803D);
  static const Color green50 = Color(0xFFEAF6EE);
  static const Color amber600 = Color(0xFFB45309);
  static const Color amber50 = Color(0xFFFDF3E6);
  // Darker than Tailwind red-600 so text on red50 passes WCAG AA (5.0:1).
  static const Color red600 = Color(0xFFC81E1E);
  static const Color red50 = Color(0xFFFDECEC);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue50 = Color(0xFFEBF1FE);

  // Status (dark)
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green950 = Color(0xFF0F2A1A);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber950 = Color(0xFF2E2210);
  static const Color red400 = Color(0xFFF87171);
  static const Color red950 = Color(0xFF331616);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue950 = Color(0xFF14213D);

  static const Color black = Color(0xFF000000);

  // Category identity hues (mid-tones; light/dark variants are derived).
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categorySky = Color(0xFF0EA5E9);
  static const Color categoryIndigo = Color(0xFF6366F1);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryPink = Color(0xFFEC4899);
  static const Color categoryRose = Color(0xFFF43F5E);
  static const Color categoryRed = Color(0xFFEF4444);
  static const Color categoryOrange = Color(0xFFF97316);
  static const Color categoryAmber = Color(0xFFF59E0B);
  static const Color categoryYellow = Color(0xFFEAB308);
  static const Color categoryGreen = Color(0xFF22C55E);
  static const Color categoryEmerald = Color(0xFF10B981);
  static const Color categoryTeal = Color(0xFF14B8A6);
  static const Color categoryCyan = Color(0xFF06B6D4);
  static const Color categorySlate = Color(0xFF64748B);
  static const Color categoryGray = Color(0xFF94A3B8);

  // Translucent overlays
  static const Color lightHover = Color(0x0A18181C);
  static const Color lightPressed = Color(0x1418181C);
  static const Color lightFocus = Color(0x735B57DB);
  static const Color lightScrim = Color(0x6618181C);
  static const Color darkHover = Color(0x0FEDEDF0);
  static const Color darkPressed = Color(0x1AEDEDF0);
  static const Color darkFocus = Color(0x8C8B89F2);
  static const Color darkScrim = Color(0x99000000);
}
