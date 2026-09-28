import 'package:flutter/widgets.dart';

/// Corner radius tokens, one per component family.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius chip = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius navItem = BorderRadius.all(Radius.circular(md));
  static const BorderRadius menu = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius tooltip = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius full = BorderRadius.all(Radius.circular(pill));
}
