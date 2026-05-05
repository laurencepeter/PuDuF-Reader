import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class FuturisticButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final bool outlined;
  final double? width;
  final double fontSize;

  const FuturisticButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = AppColors.cyan,
    this.isLoading = false,
    this.outlined = false,
    this.width,
    this.fontSize = 13,
  });

  @override
  State<FuturisticButton> createState() => _FuturisticButtonState();
}

class _FuturisticButtonState extends State<FuturisticButton>
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
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.25, end: 0.65).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, child) => Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(
                horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.outlined
                  ? null
                  : LinearGradient(
                      colors: [
                        widget.color,
                        Color.lerp(
                            widget.color, AppColors.purple, 0.5)!,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              border: widget.outlined
                  ? Border.all(color: widget.color, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.outlined
                  ? null
                  : [
                      BoxShadow(
                        color: widget.color
                            .withValues(alpha: _glow.value * 0.45),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: child,
          ),
          child: Row(
            mainAxisSize: widget.width != null
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.outlined
                        ? widget.color
                        : Colors.white,
                  ),
                )
              else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 17,
                  color: widget.outlined
                      ? widget.color
                      : Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color:
                      widget.outlined ? widget.color : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.fontSize,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
