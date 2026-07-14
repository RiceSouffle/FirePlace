import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// An interest "coal" used in onboarding and the profile interest manager.
/// Tapping ignites it: it fills with the ember gradient, the label warms to
/// cream, a handful of sparks fly, and a selection haptic fires.
class IgnitableTile extends StatefulWidget {
  const IgnitableTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<IgnitableTile> createState() => _IgnitableTileState();
}

class _IgnitableTileState extends State<IgnitableTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spark = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  final _rng = math.Random();
  List<double> _angles = const [];

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (!widget.selected) {
      _angles = List.generate(
          7, (_) => (-math.pi * 5 / 6) + _rng.nextDouble() * (math.pi * 2 / 3));
      _spark.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  void dispose() {
    _spark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.label,
      child: GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: Motion.medium,
        curve: Motion.ember,
        padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg, vertical: Insets.md),
        decoration: BoxDecoration(
          gradient: selected ? e.emberCore : null,
          color: selected ? null : e.surface2,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: selected ? Colors.transparent : e.hairline,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: e.coral.withValues(alpha: 0.34),
                    blurRadius: 22,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: Insets.sm),
                Text(
                  widget.label,
                  style: EmberText.label(
                    selected ? e.onEmber : e.textMuted,
                  ).copyWith(
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_spark.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _spark,
                      builder: (context, _) => CustomPaint(
                        painter: _SparkPainter(
                          t: _spark.value,
                          angles: _angles,
                          amber: e.amber,
                          rose: e.rose,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.t,
    required this.angles,
    required this.amber,
    required this.rose,
  });

  final double t;
  final List<double> angles;
  final Color amber;
  final Color rose;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(t);
    for (var i = 0; i < angles.length; i++) {
      final a = angles[i];
      final dist = (18 + (i.isEven ? 26 : 18)) * eased;
      final pos = origin + Offset(math.cos(a), math.sin(a)) * dist;
      final paint = Paint()
        ..color = Color.lerp(amber, rose, i / angles.length)!
            .withValues(alpha: (1 - t) * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawCircle(pos, (1 - t) * 3 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t;
}
