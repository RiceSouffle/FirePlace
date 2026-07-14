import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../providers/screen_time_provider.dart';
import '../../widgets/break_sheet.dart';
import '../feed/feed_screen.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;
  bool _breakOpen = false;

  static const _screens = [FeedScreen(), ExploreScreen(), ProfileScreen()];
  static const _labels = ['Feed', 'Explore', 'You'];

  @override
  void initState() {
    super.initState();
    final service = ref.read(screenTimeServiceProvider);
    service.startTracking();
    service.onThresholdReached = () async {
      if (!mounted || _breakOpen) return;
      _breakOpen = true;
      await showBreakSheet(context, ref.read(dailyBudgetProvider));
      _breakOpen = false;
    };
  }

  @override
  void dispose() {
    ref.read(screenTimeServiceProvider).stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: g.bg,
          border: Border(top: BorderSide(color: g.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: _Tab(
                      label: _labels[i],
                      selected: i == _index,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _index = i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label.toUpperCase(),
                style: Type.label(selected ? g.ink : g.faint)
                    .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(height: Gap.sm),
            AnimatedContainer(
              duration: Move.medium,
              curve: Move.snap,
              height: 2,
              width: selected ? 18 : 0,
              color: g.ink,
            ),
          ],
        ),
      ),
    );
  }
}
