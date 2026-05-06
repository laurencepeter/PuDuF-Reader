import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';

/// Transparent reading-lock overlay.
///
/// - PDF remains fully visible and scrollable (swipes pass through).
/// - Taps are silently consumed so the controls stay hidden.
/// - A long-press anywhere unlocks and shows the controls again.
/// - A small pulsing badge in the bottom-right indicates lock state.
class TouchLockOverlay extends StatefulWidget {
  final VoidCallback onUnlock;

  const TouchLockOverlay({super.key, required this.onUnlock});

  @override
  State<TouchLockOverlay> createState() => _TouchLockOverlayState();
}

class _TouchLockOverlayState extends State<TouchLockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    widget.onUnlock();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return GestureDetector(
      // translucent → drag/pan events fall through to the PDF viewer below
      behavior: HitTestBehavior.translucent,
      // Tap is captured and discarded — controls stay hidden
      onTap: () {},
      onLongPressStart: (_) {
        setState(() => _pressing = true);
        HapticFeedback.selectionClick();
      },
      onLongPressEnd: (_) {
        setState(() => _pressing = false);
        _onLongPress();
      },
      onLongPressCancel: () => setState(() => _pressing = false),
      child: Stack(
        children: [
          // Transparent fill — covers the full screen without obscuring the PDF
          const SizedBox.expand(),

          // Lock badge — bottom-right corner
          Positioned(
            bottom: padding.bottom + 14,
            right: 14,
            child: _LockBadge(
              pulse: _pulse,
              pressing: _pressing,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lock badge widget ─────────────────────────────────────────────────────────

class _LockBadge extends StatelessWidget {
  final AnimationController pulse;
  final bool pressing;

  const _LockBadge({required this.pulse, required this.pressing});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final glowAlpha = pressing ? 0.55 : 0.10 + pulse.value * 0.20;
        final borderAlpha = pressing ? 0.80 : 0.22 + pulse.value * 0.28;
        final iconAlpha = pressing ? 1.0 : 0.55 + pulse.value * 0.35;

        return AnimatedScale(
          scale: pressing ? 1.18 : 1.0,
          duration: 150.ms,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: borderAlpha),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: glowAlpha),
                  blurRadius: pressing ? 18 : 10,
                  spreadRadius: pressing ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  pressing ? Icons.lock_open_rounded : Icons.lock_rounded,
                  size: 15,
                  color: AppColors.cyan.withValues(alpha: iconAlpha),
                ),
                const SizedBox(width: 6),
                Text(
                  pressing ? 'Unlocking…' : 'Hold to unlock',
                  style: TextStyle(
                    color: AppColors.cyan.withValues(alpha: iconAlpha),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.3, end: 0, duration: 350.ms);
  }
}
