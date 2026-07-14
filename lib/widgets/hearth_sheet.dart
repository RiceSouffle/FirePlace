import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';
import 'ember_controls.dart';
import 'hearth.dart';

/// A 28-radius bottom sheet that rises over a dimmed hearth glow. Used for the
/// Wind-Down moment and other gentle interruptions.
Future<T?> showHearthSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final e = context.ember;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: Colors.transparent,
    barrierColor: e.inkFrame.withValues(alpha: 0.6),
    builder: (context) => _HearthSheetShell(child: Builder(builder: builder)),
  );
}

class _HearthSheetShell extends StatelessWidget {
  const _HearthSheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Container(
      decoration: BoxDecoration(
        color: e.surface2,
        borderRadius: Radii.sheetBorder,
        boxShadow: e.cardShadow(lit: true),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 220,
            child: HearthGlow(intensity: 0.7, focal: const Alignment(0, -0.2)),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Insets.xxl, Insets.md, Insets.xxl, Insets.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: Insets.xl),
                    decoration: BoxDecoration(
                      color: e.hairline,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Wind-Down sequence: a slow breathing pacer (4s in / 6s out) with a warm
/// serif prompt. Returns `true` if the user chose to rest, `false`/null to keep
/// browsing.
Future<bool?> showWindDownSheet(BuildContext context) {
  return showHearthSheet<bool>(
    context: context,
    builder: (context) => const _WindDownContent(),
  );
}

class _WindDownContent extends StatefulWidget {
  const _WindDownContent();

  @override
  State<_WindDownContent> createState() => _WindDownContentState();
}

class _WindDownContentState extends State<_WindDownContent>
    with SingleTickerProviderStateMixin {
  // 10s cycle: 4s breathe in, 6s breathe out.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    if (!(WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
        .disableAnimations)) {
      _breath.repeat();
    } else {
      _breath.value = 0.4;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  double get _scale {
    final v = _breath.value;
    if (v <= 0.4) {
      // Breathe in.
      return 0.62 + 0.38 * Curves.easeInOut.transform(v / 0.4);
    }
    // Breathe out.
    return 1.0 - 0.38 * Curves.easeInOut.transform((v - 0.4) / 0.6);
  }

  String get _phase => _breath.value <= 0.4 ? 'Breathe in' : 'Breathe out';

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, _) {
              return Center(
                child: Transform.scale(
                  scale: _scale,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: e.emberCore,
                      boxShadow: [
                        BoxShadow(
                          color: e.coral.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _phase,
                        style: EmberText.label(e.onEmber)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Insets.xl),
        Text(
          "The fire's burning low.",
          style: EmberText.displayM(e.textStrong),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Insets.sm),
        Text(
          'You’ve tended it a good while. Rest your eyes — the embers will '
          'still be warm when you return.',
          style: EmberText.body(e.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Insets.xxl),
        EmberButton(
          label: 'Rest for now',
          icon: Icons.nightlight_round,
          onPressed: () {
            Navigator.of(context).pop(true);
            SystemNavigator.pop();
          },
        ),
        const SizedBox(height: Insets.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'A little longer',
            style: EmberText.label(e.textFaint),
          ),
        ),
      ],
    );
  }
}
