import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/constants.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _ringCtrl2;
  late Animation<double> _ring1;
  late Animation<double> _ring2;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _ringCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _ring1 = CurvedAnimation(parent: _ringCtrl, curve: Curves.linear);
    _ring2 = CurvedAnimation(parent: _ringCtrl2, curve: Curves.linear);

    _init();
  }

  Future<void> _init() async {
    // Load settings and library in parallel while the splash plays
    await Future.wait([
      context.read<ThemeProvider>().load(),
      context.read<LibraryProvider>().load(),
      Future.delayed(AppConstants.splashDuration),
    ]);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _ringCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Logo(ring1: _ring1, ring2: _ring2),
              const SizedBox(height: 40),
              _AppName(),
              const SizedBox(height: 10),
              _Tagline(),
              const SizedBox(height: 64),
              _LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final Animation<double> ring1;
  final Animation<double> ring2;

  const _Logo({required this.ring1, required this.ring2});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: AnimatedBuilder(
        animation: Listenable.merge([ring1, ring2]),
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            Transform.rotate(
              angle: ring1.value * 2 * 3.14159,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: AppColors.cyan,
                    sweepAngle: 1.8,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            // Inner counter-rotating ring
            Transform.rotate(
              angle: -ring2.value * 2 * 3.14159,
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: AppColors.purple,
                    sweepAngle: 1.2,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
            // Core glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowCyan,
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.cyan,
                size: 38,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.6, 0.6), duration: 700.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 500.ms);
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double sweepAngle;
  final double strokeWidth;

  const _ArcPainter({
    required this.color,
    required this.sweepAngle,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}

// ── Text ──────────────────────────────────────────────────────────────────

class _AppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.cyan, AppColors.purpleLight],
      ).createShader(bounds),
      child: const Text(
        AppConstants.appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms);
  }
}

class _Tagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      AppConstants.appTagline,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms);
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
          final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.2, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowCyan,
                  blurRadius: 6,
                ),
              ],
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms);
  }
}
