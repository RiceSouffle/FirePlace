import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ember_theme.dart';

/// Wraps an image and turns a double-tap into a "like": a burst of amber/coral
/// embers rises and fades while a heart overshoots into place, with a soft
/// selection haptic. Single-tap is forwarded to [onTap]. The same widget powers
/// the feed card and the full-screen detail view.
class DoubleTapEmber extends StatefulWidget {
  const DoubleTapEmber({
    super.key,
    required this.child,
    required this.liked,
    required this.onLikeRequested,
    this.onTap,
    this.heartSize = 108,
  });

  final Widget child;
  final bool liked;

  /// Fired on double-tap only when the item is not already liked.
  final VoidCallback onLikeRequested;
  final VoidCallback? onTap;
  final double heartSize;

  @override
  State<DoubleTapEmber> createState() => _DoubleTapEmberState();
}

class _DoubleTapEmberState extends State<DoubleTapEmber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _bursting = false);
        _controller.reset();
      }
    });

  late final Animation<double> _heart = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 1.25)
          .chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 32,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.25, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 20,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 28),
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 20,
    ),
  ]).animate(_controller);

  final _rng = math.Random();
  List<_Ember> _embers = const [];
  bool _bursting = false;

  void _fire() {
    if (!widget.liked) widget.onLikeRequested();
    HapticFeedback.selectionClick();
    _embers = List.generate(11, (_) => _Ember.random(_rng));
    setState(() => _bursting = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Semantics(
      image: true,
      button: true,
      label: widget.liked ? 'Photograph, liked' : 'Photograph',
      hint: 'Double tap to like, tap to open',
      onTap: widget.onTap,
      child: GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _fire,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_bursting)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _EmberBurstPainter(
                      t: _controller.value,
                      embers: _embers,
                      amber: e.amber,
                      coral: e.coral,
                      rose: e.rose,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _heart.value,
                        child: Icon(
                          Icons.favorite,
                          size: widget.heartSize,
                          color: Colors.white.withValues(alpha: 0.95),
                          shadows: [
                            Shadow(
                              blurRadius: 24,
                              color: e.rose.withValues(alpha: 0.6),
                            ),
                            const Shadow(
                              blurRadius: 12,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _Ember {
  _Ember({
    required this.angle,
    required this.distance,
    required this.size,
    required this.hue,
    required this.delay,
  });

  /// Direction, biased upward so embers rise.
  final double angle;
  final double distance;
  final double size;
  final double hue; // 0 amber → 1 rose
  final double delay; // 0..0.3 stagger

  factory _Ember.random(math.Random r) {
    // Upward fan: -150°..-30° from the +x axis.
    final angle = (-math.pi * 5 / 6) + r.nextDouble() * (math.pi * 2 / 3);
    return _Ember(
      angle: angle,
      distance: 60 + r.nextDouble() * 90,
      size: 2.5 + r.nextDouble() * 4.5,
      hue: r.nextDouble(),
      delay: r.nextDouble() * 0.25,
    );
  }
}

class _EmberBurstPainter extends CustomPainter {
  _EmberBurstPainter({
    required this.t,
    required this.embers,
    required this.amber,
    required this.coral,
    required this.rose,
  });

  final double t;
  final List<_Ember> embers;
  final Color amber;
  final Color coral;
  final Color rose;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    for (final ember in embers) {
      final local = ((t - ember.delay) / (1 - ember.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeOut.transform(local);
      final travel = ember.distance * eased;
      final pos = origin +
          Offset(math.cos(ember.angle), math.sin(ember.angle)) * travel;
      // Slight upward drift + gravity settle late in the life.
      final drift = Offset(0, -8 * eased + 10 * eased * eased);
      final opacity = (1 - local) * 0.9;
      final color = Color.lerp(amber, rose, ember.hue)!;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
      canvas.drawCircle(pos + drift, ember.size * (1 - 0.4 * local), paint);
    }
  }

  @override
  bool shouldRepaint(_EmberBurstPainter old) => old.t != t;
}
