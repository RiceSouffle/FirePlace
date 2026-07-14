import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../providers/interests_provider.dart';
import '../../widgets/controls.dart';
import '../shell/app_shell.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.c;
    final reduce = reduceMotion(context);
    final selected = ref.watch(selectedInterestIdsProvider);
    final ready = selected.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FIREPLACE',
                      style: Type.label(g.dim).copyWith(letterSpacing: 3)),
                  const SizedBox(height: Gap.xxl),
                  Text('What do you\nwant to look at?',
                      style: Type.displayXL(g.ink)),
                  const SizedBox(height: Gap.md),
                  Text(
                    'Pick a few rooms. We’ll pull a slow gallery of real things '
                    '— art, cars, cats, watches — no feed, no ads, no rabbit hole.',
                    style: Type.body(g.dim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.xxl),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
                child: Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (var i = 0; i < AppConstants.allInterests.length; i++)
                      _tile(ref, i, selected, reduce),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.xl,
                  MediaQuery.of(context).padding.bottom + Gap.lg),
              decoration:
                  BoxDecoration(border: Border(top: BorderSide(color: g.hairline))),
              child: Row(
                children: [
                  Text(
                    ready
                        ? '${selected.length} SELECTED'
                        : 'PICK AT LEAST ONE',
                    style: Type.label(ready ? g.ink : g.faint),
                  ),
                  const Spacer(),
                  GalleryButton(
                    label: 'Continue',
                    icon: Icons.arrow_forward,
                    expand: false,
                    onPressed: ready ? () => _continue(context) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(WidgetRef ref, int i, List<String> selected, bool reduce) {
    final interest = AppConstants.allInterests[i];
    final tile = CategoryToggle(
      label: interest.label,
      selected: selected.contains(interest.id),
      onTap: () =>
          ref.read(selectedInterestIdsProvider.notifier).toggle(interest.id),
    );
    if (reduce) return tile;
    return tile.animate(delay: (i * 22).ms).fadeIn(duration: 240.ms);
  }

  void _continue(BuildContext context) async {
    final storage = ProviderScope.containerOf(context).read(storageServiceProvider);
    await storage.setOnboardingComplete();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Move.medium,
          pageBuilder: (_, _, _) => const AppShell(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    }
  }
}
