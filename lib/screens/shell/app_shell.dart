import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../providers/screen_time_provider.dart';
import '../../widgets/hearth_sheet.dart';
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
  bool _windDownOpen = false;

  static const _screens = [FeedScreen(), ExploreScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    final service = ref.read(screenTimeServiceProvider);
    service.startTracking();
    service.onThresholdReached = () async {
      if (!mounted || _windDownOpen) return;
      _windDownOpen = true;
      await showWindDownSheet(context);
      _windDownOpen = false;
    };
  }

  @override
  void dispose() {
    ref.read(screenTimeServiceProvider).stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _HearthNavBar(
        index: _index,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _HearthNavBar extends StatelessWidget {
  const _HearthNavBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(Icons.local_fire_department_outlined,
        Icons.local_fire_department, 'Feed'),
    _NavItem(Icons.travel_explore_outlined, Icons.travel_explore, 'Explore'),
    _NavItem(Icons.spa_outlined, Icons.spa, 'Hearth'),
  ];

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Container(
      decoration: BoxDecoration(
        color: e.surface1,
        border: Border(top: BorderSide(color: e.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Insets.md, vertical: Insets.sm),
            child: Stack(
              children: [
                // The ember glow that slides beneath the active tab.
                AnimatedAlign(
                  alignment: Alignment(-1 + index * 1.0, 0),
                  duration: Motion.medium,
                  curve: Motion.ember,
                  child: FractionallySizedBox(
                    widthFactor: 1 / _items.length,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: Insets.lg),
                      decoration: BoxDecoration(
                        gradient: e.emberCore,
                        borderRadius: BorderRadius.circular(Radii.pill),
                        boxShadow: [
                          BoxShadow(
                            color: e.coral.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _Tab(
                          item: _items[i],
                          selected: i == index,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
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
  const _Tab({required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final color = selected ? e.onEmber : e.textFaint;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      container: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon,
                size: 20, color: color),
            AnimatedSize(
              duration: Motion.medium,
              curve: Motion.ember,
              child: selected
                  ? Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: Insets.sm),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: EmberText.label(color)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
