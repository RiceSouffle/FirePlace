import 'package:flutter/widgets.dart';

/// Ember & Ash design tokens.
///
/// A single source of truth for spacing, corner radius, and motion so every
/// surface breathes to the same rhythm — magazine margins, matted corners,
/// and one warm "ember" easing curve used across the app.

/// Spacing scale (logical px). Feed uses [xl] gutters and [xxl] between cards.
abstract class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double giant = 64;
}

/// Corner radius scale. Images are matted inside [card]; sheets use [sheet].
abstract class Radii {
  static const double chip = 4;
  static const double control = 12;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static const Radius cardR = Radius.circular(card);
  static const Radius sheetR = Radius.circular(sheet);
  static const BorderRadius cardBorder = BorderRadius.all(cardR);
  static const BorderRadius sheetBorder =
      BorderRadius.vertical(top: sheetR);
}

/// Motion language. One decisive-but-soft [ember] curve unifies transitions;
/// [hearth] is the shared 6s cadence of the living fire.
abstract class Motion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration hearth = Duration(seconds: 6);
  static const Duration windDown = Duration(milliseconds: 1500);

  /// Signature curve: quick to commit, gentle to land — an ember settling.
  static const Cubic ember = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Cubic emberIn = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Staggered "kindling" entrance interval between successive items.
  static const Duration kindlingStep = Duration(milliseconds: 55);
}
