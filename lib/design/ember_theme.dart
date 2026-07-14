import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ember_tokens.dart';

/// The Ember & Ash palette, exposed as a [ThemeExtension] so every widget can
/// read semantic warm tokens (`context.ember.coral`) instead of hard-coding hex.
///
/// The design rule that ties the whole app together: photographs are always
/// matted on an [inkFrame] plate with a [hairline] edge — in *both* light and
/// dark — so unpredictable Reddit imagery always reads as "a hung print".
@immutable
class EmberColors extends ThemeExtension<EmberColors> {
  const EmberColors({
    required this.brightness,
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.inkFrame,
    required this.hairline,
    required this.amber,
    required this.coral,
    required this.rose,
    required this.glow,
    required this.textStrong,
    required this.textMuted,
    required this.textFaint,
    required this.sage,
    required this.likeColor,
    required this.saveColor,
  });

  final Brightness brightness;

  /// Layered backgrounds, deepest → highest.
  final Color surface0;
  final Color surface1;
  final Color surface2;
  final Color surface3;

  /// The matting plate under every photo (constant near-black in both themes).
  final Color inkFrame;

  /// 1px frame edge around matted prints.
  final Color hairline;

  /// Ember accent trio (amber → coral → rose).
  final Color amber;
  final Color coral;
  final Color rose;

  /// Warm bloom used for lit-from-within glows.
  final Color glow;

  final Color textStrong;
  final Color textMuted;
  final Color textFaint;

  /// The "cooled" hue a budget ring lerps toward when you're within budget.
  final Color sage;

  final Color likeColor;
  final Color saveColor;

  bool get isDark => brightness == Brightness.dark;

  /// Foreground for anything painted on the ember gradient. A deep warm ink
  /// reads with strong contrast on the bright amber→rose stops in both themes
  /// (white fails WCAG on the amber end), and suits the "lit coal" metaphor.
  Color get onEmber => const Color(0xFF20130A);

  /// The core ember gradient — buttons, active chips, the like heart, the ring.
  LinearGradient get emberCore => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [amber, coral, rose],
      );

  /// A softer horizontal wash for large fills (hero glows, CTAs).
  LinearGradient get emberWash => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [amber, coral, rose],
      );

  /// Warm two-layer shadow. [lit] adds a coral key so primary/interactive
  /// elements read as glowing from within rather than casting a grey drop.
  List<BoxShadow> cardShadow({bool lit = false}) {
    final ambientAlpha = isDark ? 0.45 : 0.12;
    final keyAlpha = isDark ? 0.20 : 0.10;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: ambientAlpha),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
      if (lit)
        BoxShadow(
          color: coral.withValues(alpha: keyAlpha),
          blurRadius: 24,
          spreadRadius: -4,
        ),
    ];
  }

  /// A vertical scrim laid over imagery so cream labels stay legible.
  LinearGradient scrim({double strength = 0.88}) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          inkFrame.withValues(alpha: strength),
        ],
        stops: const [0.55, 1.0],
      );

  static const EmberColors dark = EmberColors(
    brightness: Brightness.dark,
    surface0: Color(0xFF14100E),
    surface1: Color(0xFF1D1815),
    surface2: Color(0xFF272019),
    surface3: Color(0xFF33291F),
    inkFrame: Color(0xFF0C0A09),
    hairline: Color(0xFF4A3B2C),
    amber: Color(0xFFF5A623),
    coral: Color(0xFFF26A4B),
    rose: Color(0xFFE14B6A),
    glow: Color(0xFFFF8A4C),
    textStrong: Color(0xFFF7EFE4),
    textMuted: Color(0xFFCDBFAE),
    textFaint: Color(0xFF93877A),
    sage: Color(0xFF8FB08A),
    likeColor: Color(0xFFE14B6A),
    saveColor: Color(0xFFF5A623),
  );

  static const EmberColors light = EmberColors(
    brightness: Brightness.light,
    surface0: Color(0xFFFAF4EA),
    surface1: Color(0xFFF3EADB),
    surface2: Color(0xFFECE0CD),
    surface3: Color(0xFFE0D0B8),
    inkFrame: Color(0xFF0C0A09),
    hairline: Color(0xFFE0D0B8),
    amber: Color(0xFFE8901A),
    coral: Color(0xFFD9542F),
    rose: Color(0xFFC63B57),
    glow: Color(0xFFF0A860),
    textStrong: Color(0xFF241B14),
    textMuted: Color(0xFF5C4E40),
    textFaint: Color(0xFF8B7B69),
    sage: Color(0xFF4F7057),
    likeColor: Color(0xFFC63B57),
    saveColor: Color(0xFFD9542F),
  );

  @override
  EmberColors copyWith({
    Brightness? brightness,
    Color? surface0,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? inkFrame,
    Color? hairline,
    Color? amber,
    Color? coral,
    Color? rose,
    Color? glow,
    Color? textStrong,
    Color? textMuted,
    Color? textFaint,
    Color? sage,
    Color? likeColor,
    Color? saveColor,
  }) {
    return EmberColors(
      brightness: brightness ?? this.brightness,
      surface0: surface0 ?? this.surface0,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      inkFrame: inkFrame ?? this.inkFrame,
      hairline: hairline ?? this.hairline,
      amber: amber ?? this.amber,
      coral: coral ?? this.coral,
      rose: rose ?? this.rose,
      glow: glow ?? this.glow,
      textStrong: textStrong ?? this.textStrong,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      sage: sage ?? this.sage,
      likeColor: likeColor ?? this.likeColor,
      saveColor: saveColor ?? this.saveColor,
    );
  }

  @override
  EmberColors lerp(ThemeExtension<EmberColors>? other, double t) {
    if (other is! EmberColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return EmberColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      surface0: c(surface0, other.surface0),
      surface1: c(surface1, other.surface1),
      surface2: c(surface2, other.surface2),
      surface3: c(surface3, other.surface3),
      inkFrame: c(inkFrame, other.inkFrame),
      hairline: c(hairline, other.hairline),
      amber: c(amber, other.amber),
      coral: c(coral, other.coral),
      rose: c(rose, other.rose),
      glow: c(glow, other.glow),
      textStrong: c(textStrong, other.textStrong),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      sage: c(sage, other.sage),
      likeColor: c(likeColor, other.likeColor),
      saveColor: c(saveColor, other.saveColor),
    );
  }
}

/// Ergonomic access: `context.ember.coral`.
extension EmberContext on BuildContext {
  EmberColors get ember => Theme.of(this).extension<EmberColors>()!;
}

/// Typography — a deliberate two-voice system.
///
/// Fraunces (a high-contrast old-style serif) is the *human* voice: headlines,
/// the wordmark, and numbers that matter. Inter is the *functional* voice for
/// all chrome. The same post title is dense Inter on the feed but promotes to
/// Fraunces italic in Detail — a small luxury that rewards tapping in.
abstract class EmberText {
  static TextStyle displayXL(Color color) => GoogleFonts.fraunces(
        fontSize: 40,
        height: 44 / 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.5,
        color: color,
      );

  static TextStyle displayL(Color color) => GoogleFonts.fraunces(
        fontSize: 30,
        height: 36 / 30,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        color: color,
      );

  static TextStyle displayM(Color color) => GoogleFonts.fraunces(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: color,
      );

  /// The pull-quote — post title promoted in Detail.
  static TextStyle serifQuote(Color color) => GoogleFonts.fraunces(
        fontSize: 21,
        height: 30 / 21,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: color,
      );

  static TextStyle title(Color color) => GoogleFonts.inter(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label(Color color) => GoogleFonts.inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// The recurring all-caps attribution fingerprint.
  static TextStyle museum(Color color) => GoogleFonts.inter(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: color,
      );
}

/// Assembles [ThemeData] for both brightnesses from the Ember tokens.
abstract class EmberTheme {
  static ThemeData light() => _build(EmberColors.light);
  static ThemeData dark() => _build(EmberColors.dark);

  static ThemeData _build(EmberColors e) {
    final scheme = ColorScheme(
      brightness: e.brightness,
      primary: e.coral,
      onPrimary: e.isDark ? const Color(0xFF1A0E08) : Colors.white,
      secondary: e.amber,
      onSecondary: const Color(0xFF1A0E08),
      tertiary: e.rose,
      onTertiary: Colors.white,
      error: e.rose,
      onError: Colors.white,
      surface: e.surface1,
      onSurface: e.textStrong,
      surfaceContainerLowest: e.surface0,
      surfaceContainerLow: e.surface1,
      surfaceContainer: e.surface2,
      surfaceContainerHigh: e.surface3,
      surfaceContainerHighest: e.surface3,
      onSurfaceVariant: e.textMuted,
      outline: e.hairline,
      outlineVariant: e.hairline,
    );

    final base = e.isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: e.textStrong,
      displayColor: e.textStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: e.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: e.surface0,
      canvasColor: e.surface0,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      extensions: [e],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: e.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: e.surface2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sheet),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: e.surface2,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: Radii.sheetBorder,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: e.surface3,
        contentTextStyle: EmberText.label(e.textStrong),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control),
        ),
      ),
      iconTheme: IconThemeData(color: e.textStrong),
      dividerTheme: DividerThemeData(color: e.hairline, thickness: 1),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(e.surface2),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.control),
            ),
          ),
        ),
      ),
    );
  }
}
