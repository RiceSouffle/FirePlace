import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// A single app-wide "hearth clock" — one [AnimationController] shared by every
/// living-ember surface (feed header, profile number, empty states). Running one
/// ticker instead of a dozen keeps the always-alive glow GPU- and battery-cheap.
///
/// Reduced-motion is honoured: when the OS requests it, the clock parks at its
/// midpoint so surfaces render a calm, static glow.
class HearthClock extends InheritedWidget {
  const HearthClock({super.key, required this.pulse, required super.child});

  /// A triangle wave in [0, 1] over 6 seconds.
  final Animation<double> pulse;

  static Animation<double> of(BuildContext context) {
    final clock =
        context.dependOnInheritedWidgetOfExactType<HearthClock>();
    return clock?.pulse ?? const AlwaysStoppedAnimation<double>(0.5);
  }

  @override
  bool updateShouldNotify(HearthClock oldWidget) => pulse != oldWidget.pulse;
}

/// Wrap the app once to provide the shared clock to the whole tree.
class HearthTicker extends StatefulWidget {
  const HearthTicker({super.key, required this.child});
  final Widget child;

  @override
  State<HearthTicker> createState() => _HearthTickerState();
}

class _HearthTickerState extends State<HearthTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Motion.hearth, value: 0.5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      HearthClock(pulse: _controller, child: widget.child);
}

/// The living fire: layered blurred ember blobs that drift and breathe. No image
/// assets — it's the brand, drawn on the GPU. Place it behind content as a
/// background layer (it paints nothing but glow, over a transparent ground).
class HearthGlow extends StatelessWidget {
  const HearthGlow({
    super.key,
    this.intensity = 1.0,
    this.focal = const Alignment(0, 0.35),
  });

  /// Overall strength of the glow (0 hides it, 1 is full).
  final double intensity;

  /// Where the fire sits within the box.
  final Alignment focal;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final pulse = HearthClock.of(context);
    // The fire is bolder on dark ash, a gentle sunrise wash on paper.
    final strength = intensity * (e.isDark ? 1.0 : 0.55);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _HearthPainter(
            t: pulse.value,
            amber: e.amber,
            coral: e.coral,
            rose: e.rose,
            strength: strength,
            focal: focal,
          ),
        ),
      ),
    );
  }
}

class _HearthPainter extends CustomPainter {
  _HearthPainter({
    required this.t,
    required this.amber,
    required this.coral,
    required this.rose,
    required this.strength,
    required this.focal,
  });

  final double t;
  final Color amber;
  final Color coral;
  final Color rose;
  final double strength;
  final Alignment focal;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final phase = t * 2 * math.pi;
    final base = focal.alongSize(size);
    final unit = size.shortestSide;

    // Three drifting embers of decreasing warmth, back to front.
    _blob(canvas, base, unit, phase, 0, amber, 0.22, 0.95);
    _blob(canvas, base, unit, phase, 2.1, coral, 0.26, 0.75);
    _blob(canvas, base, unit, phase, 4.2, rose, 0.20, 0.55);
  }

  void _blob(
    Canvas canvas,
    Offset base,
    double unit,
    double phase,
    double seed,
    Color color,
    double alpha,
    double radiusFactor,
  ) {
    // Barely-perceptible breathing: opacity 0.5→0.85, radius drifts with t.
    final breathe = 0.72 + 0.28 * (0.5 + 0.5 * math.sin(phase + seed));
    final dx = math.sin(phase * 0.8 + seed) * unit * 0.10;
    final dy = math.cos(phase * 0.6 + seed * 1.3) * unit * 0.06;
    final center = base + Offset(dx, dy);
    final radius = unit * radiusFactor * breathe;
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * strength * breathe)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, unit * 0.35);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_HearthPainter old) =>
      old.t != t || old.strength != strength || old.focal != focal;
}
