import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../models/interest.dart';
import '../../providers/interests_provider.dart';
import '../../widgets/ember_controls.dart';
import '../../widgets/hearth.dart';
import '../../widgets/ignitable_tile.dart';
import '../shell/app_shell.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = context.ember;
    final reduce = reduceMotion(context);
    final selectedIds = ref.watch(selectedInterestIdsProvider);
    final count = selectedIds.length;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -80,
            left: 0,
            right: 0,
            height: 380,
            child: HearthGlow(intensity: 0.9, focal: Alignment(0, 0.1)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Insets.xxl, Insets.xxxl, Insets.xxl, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: e.coral, size: 30),
                          const SizedBox(width: Insets.sm),
                          Text('FIREPLACE',
                              style: EmberText.museum(e.textMuted)
                                  .copyWith(letterSpacing: 3)),
                        ],
                      ),
                      const SizedBox(height: Insets.xxl),
                      if (reduce)
                        Text('What warms you?',
                            style: EmberText.displayXL(e.textStrong))
                      else
                        Text('What warms you?',
                                style: EmberText.displayXL(e.textStrong))
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2, curve: Motion.ember),
                      const SizedBox(height: Insets.md),
                      if (reduce)
                        Text(
                          'Pick the things you love. We’ll tend a small, curated '
                          'fire of them — no algorithms, no ads, no endless scroll.',
                          style: EmberText.body(e.textMuted),
                        )
                      else
                        Text(
                          'Pick the things you love. We’ll tend a small, curated '
                          'fire of them — no algorithms, no ads, no endless scroll.',
                          style: EmberText.body(e.textMuted),
                        ).animate(delay: 120.ms).fadeIn(duration: 500.ms),
                    ],
                  ),
                ),
                const SizedBox(height: Insets.xxl),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        Insets.xxl, 0, Insets.xxl, Insets.xxl),
                    child: Wrap(
                      spacing: Insets.sm + 2,
                      runSpacing: Insets.sm + 2,
                      children: [
                        for (var i = 0;
                            i < AppConstants.allInterests.length;
                            i++)
                          _tile(ref, AppConstants.allInterests[i], selectedIds,
                              i, reduce),
                      ],
                    ),
                  ),
                ),
                _Footer(count: count),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    WidgetRef ref,
    Interest interest,
    List<String> selectedIds,
    int index,
    bool reduce,
  ) {
    final tile = IgnitableTile(
      emoji: interest.emoji,
      label: interest.label,
      selected: selectedIds.contains(interest.id),
      onTap: () =>
          ref.read(selectedInterestIdsProvider.notifier).toggle(interest.id),
    );
    if (reduce) return tile;
    return tile
        .animate(delay: (index * 28).ms)
        .fadeIn(duration: 360.ms)
        .slideY(begin: 0.25, curve: Motion.ember);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final ready = count > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Insets.xxl,
        Insets.lg,
        Insets.xxl,
        MediaQuery.of(context).padding.bottom + Insets.lg,
      ),
      decoration: BoxDecoration(
        color: e.surface0.withValues(alpha: 0.0),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [e.surface0.withValues(alpha: 0), e.surface0],
          stops: const [0, 0.35],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ready
                ? '$count spark${count == 1 ? '' : 's'} lit'
                : 'Tap a few to light the fire',
            style: EmberText.label(ready ? e.textStrong : e.textFaint),
          ),
          const SizedBox(height: Insets.md),
          EmberButton(
            label: ready ? 'Light the fire' : 'Choose at least one',
            icon: ready ? Icons.local_fire_department : null,
            glow: (count / 6).clamp(0.15, 1.0),
            onPressed: ready
                ? () => _continue(context)
                : null,
          ),
        ],
      ),
    );
  }

  void _continue(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final storage = container.read(storageServiceProvider);
    await storage.setOnboardingComplete();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Motion.slow,
          pageBuilder: (_, _, _) => const AppShell(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }
}
