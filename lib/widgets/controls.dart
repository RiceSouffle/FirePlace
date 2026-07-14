import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// Primary action. Filled = an ink block with paper text (inversion is the only
/// "accent" in this system). Outline = a hairline box. Hard edges throughout.
class GalleryButton extends StatelessWidget {
  const GalleryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.filled = true,
    this.expand = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final enabled = onPressed != null;
    final fg = filled
        ? (enabled ? g.onInk : g.faint)
        : (enabled ? g.ink : g.faint);

    final child = Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: Gap.xxl),
      decoration: BoxDecoration(
        color: filled ? (enabled ? g.ink : g.surfaceHigh) : Colors.transparent,
        border: filled ? null : Border.all(color: enabled ? g.ink : g.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: Gap.sm),
          ],
          Text(label.toUpperCase(),
              style: Type.label(fg).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        child: expand ? SizedBox(width: double.infinity, child: child) : child,
      ),
    );
  }
}

/// A category chip. Selected inverts to an ink block; unselected is a hairline
/// outline. No colour, no emoji — just type and inversion.
class CategoryToggle extends StatelessWidget {
  const CategoryToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: Move.fast,
          curve: Move.sharp,
          padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg, vertical: Gap.sm + 2),
          decoration: BoxDecoration(
            color: selected ? g.ink : Colors.transparent,
            border: Border.all(color: selected ? g.ink : g.hairline),
          ),
          child: Text(
            label.toUpperCase(),
            style: Type.label(selected ? g.onInk : g.ink).copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
