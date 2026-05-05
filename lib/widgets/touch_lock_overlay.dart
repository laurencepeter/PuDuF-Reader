import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../config/constants.dart';

class TouchLockOverlay extends StatefulWidget {
  final VoidCallback onUnlock;

  const TouchLockOverlay({super.key, required this.onUnlock});

  @override
  State<TouchLockOverlay> createState() => _TouchLockOverlayState();
}

class _TouchLockOverlayState extends State<TouchLockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  double _dragStartY = 0;
  double _progress = 0; // 0..1 as user swipes up
  bool _unlocking = false;

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

  // ── Gesture handling ──────────────────────────────────────────────────

  void _onDragStart(DragStartDetails d) {
    _dragStartY = d.globalPosition.dy;
    setState(() => _progress = 0);
  }

  void _onDragUpdate(DragUpdateDetails d, double screenH) {
    final delta = _dragStartY - d.globalPosition.dy;
    setState(() {
      _progress =
          (delta / (screenH * AppConstants.touchLockSwipeThreshold))
              .clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_progress >= 1.0 && !_unlocking) {
      _unlocking = true;
      widget.onUnlock();
    } else {
      setState(() => _progress = 0);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: (d) => _onDragUpdate(d, screenH),
      onVerticalDragEnd: _onDragEnd,
      child: Container(
        color: AppColors.background.withValues(alpha: 0.90),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LockIcon(pulse: _pulse),
              const SizedBox(height: 32),
              _StatusText(),
              const SizedBox(height: 52),
              _SwipeTrack(progress: _progress, pulse: _pulse),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  final AnimationController pulse;

  const _LockIcon({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.cyan
                .withValues(alpha: 0.28 + pulse.value * 0.42),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan
                  .withValues(alpha: 0.08 + pulse.value * 0.18),
              blurRadius: 30,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Icon(
          Icons.lock_rounded,
          size: 42,
          color: AppColors.cyan
              .withValues(alpha: 0.55 + pulse.value * 0.45),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.75, 0.75), duration: 400.ms,
            curve: Curves.elasticOut);
  }
}

class _StatusText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'READING LOCK',
          style: TextStyle(
            color: AppColors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
        const SizedBox(height: 8),
        const Text(
          'Accidental touches are blocked',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms),
      ],
    );
  }
}

class _SwipeTrack extends StatelessWidget {
  final double progress;
  final AnimationController pulse;

  const _SwipeTrack({required this.progress, required this.pulse});

  @override
  Widget build(BuildContext context) {
    const trackH = 130.0;
    const trackW = 56.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Track outline
            Container(
              width: trackW,
              height: trackH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackW / 2),
                border: Border.all(
                    color: AppColors.textMuted, width: 1.5),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: 50.ms,
              width: trackW,
              height: (trackH * progress).clamp(0, trackH),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackW / 2),
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Thumb arrow
            Positioned(
              bottom: 10,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -pulse.value * 7),
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: 200.ms,
          child: Text(
            progress > 0
                ? 'Keep swiping… ${(progress * 100).toInt()}%'
                : 'Swipe up to unlock',
            key: ValueKey(progress > 0),
            style: TextStyle(
              color:
                  progress > 0 ? AppColors.cyan : AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 240.ms);
  }
}
