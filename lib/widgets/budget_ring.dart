import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design/ember_theme.dart';

/// A ring that visualises today's browsing against a chosen budget. It fills
/// clockwise and — crucially — *cools* from warm ember toward calm [sage] as you
/// approach the budget, reframing "time spent" as a good full session settling
/// down rather than a punishing red alarm.
class BudgetRing extends StatelessWidget {
  const BudgetRing({
    super.key,
    required this.progress,
    this.diameter = 220,
    this.stroke = 12,
    this.child,
  });

  /// minutes-used / budget-minutes. May exceed 1 (over budget → full, sage).
  final double progress;
  final double diameter;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _BudgetRingPainter(
          progress: progress.clamp(0.0, 1.0),
          stroke: stroke,
          track: e.surface2,
          amber: e.amber,
          coral: e.coral,
          rose: e.rose,
          sage: e.sage,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _BudgetRingPainter extends CustomPainter {
  _BudgetRingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.amber,
    required this.coral,
    required this.rose,
    required this.sage,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Color amber;
  final Color coral;
  final Color rose;
  final Color sage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (progress <= 0) return;

    // Warmth cools toward sage as the session approaches budget.
    Color cool(Color c) => Color.lerp(c, sage, progress * 0.85)!;
    final sweep = 2 * math.pi * progress;
    const start = -math.pi / 2;

    final shader = SweepGradient(
      startAngle: start,
      endAngle: start + 2 * math.pi,
      colors: [cool(amber), cool(coral), cool(rose), cool(amber)],
      stops: const [0.0, 0.4, 0.75, 1.0],
      transform: GradientRotation(start),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_BudgetRingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.track != track ||
      old.amber != amber ||
      old.coral != coral ||
      old.rose != rose ||
      old.sage != sage;
}
