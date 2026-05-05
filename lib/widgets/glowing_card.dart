import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class GlowingCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool pulsate;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.cyan,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPress,
    this.pulsate = true,
  });

  @override
  State<GlowingCard> createState() => _GlowingCardState();
}

class _GlowingCardState extends State<GlowingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _glow = Tween<double>(begin: 0.25, end: 0.65).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.pulsate) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _pressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.glowColor.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor
                      .withValues(alpha: _glow.value * 0.3),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: widget.glowColor
                      .withValues(alpha: _glow.value * 0.1),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(widget.borderRadius),
              child: child,
            ),
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
