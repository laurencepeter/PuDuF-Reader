import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Space / futuristic dark palette
  static const Color background = Color(0xFF080C1A);
  static const Color surface = Color(0xFF0F1629);
  static const Color card = Color(0xFF141C35);
  static const Color cardBorder = Color(0xFF1E2A4A);

  // Neon accents
  static const Color cyan = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF7B2FBE);
  static const Color purpleLight = Color(0xFFBD7BFF);
  static const Color orange = Color(0xFFFF6B35);
  static const Color green = Color(0xFF00FF87);
  static const Color red = Color(0xFFFF3D71);

  // Text
  static const Color textPrimary = Color(0xFFEAEEFF);
  static const Color textSecondary = Color(0xFF7B8DB0);
  static const Color textMuted = Color(0xFF3D4F70);

  // Glow colours (semi-transparent)
  static const Color glowCyan = Color(0x4000D4FF);
  static const Color glowPurple = Color(0x407B2FBE);
  static const Color glowOrange = Color(0x40FF6B35);

  // ── Reading mode colours ────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);

  static const Color darkBackground = Color(0xFF0F1629);
  static const Color darkText = Color(0xFFEAEEFF);

  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledText = Color(0xFFFFFFFF);

  static const Color lowLightBackground = Color(0xFF2C1F0E);
  static const Color lowLightText = Color(0xFFFFDDA0);

  static const Color nightBackground = Color(0xFF140000);
  static const Color nightText = Color(0xFFFF8080);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF080C1A), Color(0xFF0D1530)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
