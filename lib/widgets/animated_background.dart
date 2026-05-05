import 'dart:math';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _gradientController;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _particles =
        List.generate(70, (_) => _Particle.random(rnd));

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge(
              [_particleController, _gradientController]),
          builder: (_, __) => CustomPaint(
            painter: _BackgroundPainter(
              particles: _particles,
              progress: _particleController.value,
              gradientT: _gradientController.value,
            ),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;
  final bool isCyan; // alternates cyan / white

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
    required this.isCyan,
  });

  factory _Particle.random(Random rnd) => _Particle(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        size: rnd.nextDouble() * 2.2 + 0.4,
        speed: rnd.nextDouble() * 0.018 + 0.004,
        opacity: rnd.nextDouble() * 0.55 + 0.1,
        angle: rnd.nextDouble() * 2 * pi,
        isCyan: rnd.nextBool(),
      );
}

// ── Painter ───────────────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double gradientT;

  _BackgroundPainter({
    required this.particles,
    required this.progress,
    required this.gradientT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            -0.6 + gradientT * 0.8,
            -0.4 + gradientT * 0.4,
          ),
          radius: 1.5,
          colors: const [Color(0xFF0D1530), Color(0xFF080C1A)],
        ).createShader(bgRect),
    );

    // Nebula blobs
    _drawNebula(canvas, size,
        cx: 0.78, cy: 0.18, color: AppColors.glowPurple, t: gradientT);
    _drawNebula(canvas, size,
        cx: 0.18, cy: 0.72, color: AppColors.glowCyan, t: 1 - gradientT);
    _drawNebula(canvas, size,
        cx: 0.5, cy: 0.5, color: const Color(0x18FF6B35), t: gradientT);

    // Subtle grid
    final gridPaint = Paint()
      ..color = const Color(0xFF1E2A4A).withValues(alpha: 0.22)
      ..strokeWidth = 0.5;
    const gs = 56.0;
    for (double x = 0; x < size.width; x += gs) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gs) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Particles / stars
    for (final p in particles) {
      final px =
          (p.x + progress * p.speed * cos(p.angle)) % 1.0;
      final py =
          (p.y + progress * p.speed * sin(p.angle)) % 1.0;

      final base = p.isCyan ? AppColors.cyan : AppColors.textPrimary;

      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size,
        Paint()..color = base.withValues(alpha: p.opacity),
      );

      if (p.size > 1.6) {
        canvas.drawCircle(
          Offset(px * size.width, py * size.height),
          p.size * 2.5,
          Paint()
            ..color = base.withValues(alpha: p.opacity * 0.25)
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  void _drawNebula(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required Color color,
    required double t,
  }) {
    final rect = Rect.fromCenter(
      center: Offset(cx * size.width, cy * size.height),
      width: size.width * (0.65 + t * 0.1),
      height: size.height * (0.45 + t * 0.08),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader =
            RadialGradient(colors: [color, Colors.transparent])
                .createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.progress != progress || old.gradientT != gradientT;
}
