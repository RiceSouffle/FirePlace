import 'package:flutter/widgets.dart';

/// Gallery design tokens — a modern, monochrome system.
///
/// Hard edges, a tight grid, and crisp snap/crossfade motion. No gradients, no
/// rounded-everything, no glow. The chrome is a neutral gallery wall; the
/// artwork carries all the colour.

/// Spacing scale (logical px).
abstract class Gap {
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

/// Corner radius — mostly hard. A gallery frame is square.
abstract class Corner {
  static const double none = 0;
  static const double xs = 2;
  static const double sm = 4;
  static const double pill = 999;

  static const BorderRadius r2 = BorderRadius.all(Radius.circular(2));
  static const BorderRadius r4 = BorderRadius.all(Radius.circular(4));
}

/// Motion — decisive and clean. Snap in, crossfade, no overshoot.
abstract class Move {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);

  /// Crisp, confident easing — quick out, settled landing. No bounce.
  static const Cubic snap = Cubic(0.22, 1, 0.36, 1);
  static const Cubic sharp = Cubic(0.4, 0, 0.2, 1);

  static const Duration staggerStep = Duration(milliseconds: 45);
}

/// Whether the OS asked for reduced motion; entrance animations gate on it.
bool reduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

/// Wikimedia Commons blocks image requests without a descriptive User-Agent,
/// so every network image carries one.
const Map<String, String> kImageHeaders = {
  'User-Agent':
      'FirePlace/1.0 (Flutter gallery app; +https://github.com/RiceSouffle/FirePlace)',
};
