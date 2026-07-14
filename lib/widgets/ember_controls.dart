import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// The primary call to action — an ember-gradient button that glows warmer as
/// [glow] rises (the onboarding CTA brightens as more sparks are lit). Passing a
/// null [onPressed] renders it dim and disabled.
class EmberButton extends StatelessWidget {
  const EmberButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.glow = 1.0,
    this.expand = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// 0 → no bloom, 1 → full lit-from-within glow.
  final double glow;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final enabled = onPressed != null;
    final child = AnimatedContainer(
      duration: Motion.medium,
      curve: Motion.ember,
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
      decoration: BoxDecoration(
        gradient: enabled ? e.emberCore : null,
        color: enabled ? null : e.surface2,
        borderRadius: BorderRadius.circular(Radii.control),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: e.coral.withValues(alpha: 0.34 * glow),
                  blurRadius: 28 * glow + 4,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 20,
                color: enabled ? e.onEmber : e.textFaint),
            const SizedBox(width: Insets.sm),
          ],
          Text(
            label,
            style: EmberText.title(enabled ? e.onEmber : e.textFaint),
          ),
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
        child: expand
            ? SizedBox(width: double.infinity, child: child)
            : child,
      ),
    );
  }
}

/// A filter pill. When [selected] it fills with the ember gradient and gains a
/// warm-key glow; otherwise it's a quiet outlined surface. Animates between the
/// two states so the "glow" appears to slide between chips as selection moves.
class EmberChip extends StatelessWidget {
  const EmberChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
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
        duration: Motion.fast,
        curve: Motion.ember,
        padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg, vertical: Insets.sm + 2),
        decoration: BoxDecoration(
          gradient: selected ? e.emberCore : null,
          color: selected ? null : e.surface2,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: selected ? Colors.transparent : e.hairline,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: e.coral.withValues(alpha: 0.30),
                    blurRadius: 18,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: Insets.xs + 2),
            ],
            Text(
              label,
              style: EmberText.label(
                selected ? e.onEmber : e.textMuted,
              ).copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
