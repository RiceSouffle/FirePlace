import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// The Gallery palette — a strict monochrome system exposed as a
/// [ThemeExtension]. There is no accent hue: the artwork is the only colour on
/// screen. Emphasis comes from weight, scale, and inversion (an ink block with
/// paper text), never from a coloured rail.
@immutable
class GalleryColors extends ThemeExtension<GalleryColors> {
  const GalleryColors({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.hairline,
    required this.ink,
    required this.dim,
    required this.faint,
  });

  final Brightness brightness;

  /// The gallery wall.
  final Color bg;

  /// Slightly raised panels (cards, sheets, nav).
  final Color surface;
  final Color surfaceHigh;

  /// 1px separators.
  final Color hairline;

  /// Primary text / foreground.
  final Color ink;

  /// Secondary text.
  final Color dim;

  /// Tertiary text / disabled.
  final Color faint;

  bool get isDark => brightness == Brightness.dark;

  /// Foreground for anything painted on an ink-filled (inverted) surface.
  Color get onInk => bg;

  static const GalleryColors dark = GalleryColors(
    brightness: Brightness.dark,
    bg: Color(0xFF0A0A0B),
    surface: Color(0xFF141416),
    surfaceHigh: Color(0xFF1D1D20),
    hairline: Color(0xFF2C2C31),
    ink: Color(0xFFFAFAF7),
    dim: Color(0xFFA2A2A8),
    faint: Color(0xFF66666C),
  );

  static const GalleryColors light = GalleryColors(
    brightness: Brightness.light,
    bg: Color(0xFFFAFAF7),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF1F1EC),
    hairline: Color(0xFFE2E2DC),
    ink: Color(0xFF0A0A0B),
    dim: Color(0xFF55555A),
    faint: Color(0xFF9A9A9F),
  );

  @override
  GalleryColors copyWith({
    Brightness? brightness,
    Color? bg,
    Color? surface,
    Color? surfaceHigh,
    Color? hairline,
    Color? ink,
    Color? dim,
    Color? faint,
  }) {
    return GalleryColors(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      hairline: hairline ?? this.hairline,
      ink: ink ?? this.ink,
      dim: dim ?? this.dim,
      faint: faint ?? this.faint,
    );
  }

  @override
  GalleryColors lerp(ThemeExtension<GalleryColors>? other, double t) {
    if (other is! GalleryColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GalleryColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      hairline: c(hairline, other.hairline),
      ink: c(ink, other.ink),
      dim: c(dim, other.dim),
      faint: c(faint, other.faint),
    );
  }
}

/// Ergonomic access: `context.c.ink`.
extension GalleryContext on BuildContext {
  GalleryColors get c => Theme.of(this).extension<GalleryColors>()!;
}

/// Typography — Space Grotesk (a wide, modern grotesk) for everything spoken,
/// Space Mono for the captions, labels, and numbers that read like an index or
/// a museum wall-label. Tabular figures keep numeric columns aligned.
abstract class Type {
  static TextStyle displayXL(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: color,
      );

  static TextStyle displayL(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle displayM(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        height: 1.1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle title(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// The wall-label voice: uppercase, tracked mono. Uppercase the string yourself.
  static TextStyle label(Color color) => GoogleFonts.spaceMono(
        fontSize: 11.5,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.3,
        color: color,
      );

  /// Mono caption / metadata (mixed case).
  static TextStyle mono(Color color) => GoogleFonts.spaceMono(
        fontSize: 12.5,
        height: 1.4,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: color,
      );

  /// Big tabular numbers (session time, indices).
  static TextStyle number(Color color) => GoogleFonts.spaceMono(
        fontSize: 44,
        height: 1.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

abstract class GalleryTheme {
  static ThemeData light() => _build(GalleryColors.light);
  static ThemeData dark() => _build(GalleryColors.dark);

  static ThemeData _build(GalleryColors g) {
    final scheme = ColorScheme(
      brightness: g.brightness,
      primary: g.ink,
      onPrimary: g.bg,
      secondary: g.ink,
      onSecondary: g.bg,
      error: g.ink,
      onError: g.bg,
      surface: g.surface,
      onSurface: g.ink,
      surfaceContainerLowest: g.bg,
      surfaceContainerLow: g.surface,
      surfaceContainer: g.surface,
      surfaceContainerHigh: g.surfaceHigh,
      surfaceContainerHighest: g.surfaceHigh,
      onSurfaceVariant: g.dim,
      outline: g.hairline,
      outlineVariant: g.hairline,
    );

    final base = g.isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme)
        .apply(bodyColor: g.ink, displayColor: g.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: g.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: g.bg,
      canvasColor: g.bg,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [g],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: g.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: g.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Corner.r2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: g.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      dividerTheme: DividerThemeData(color: g.hairline, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: g.ink),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(g.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Corner.r2),
          ),
        ),
      ),
    );
  }
}
