import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/constants.dart';
import '../models/reading_settings.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/glowing_card.dart';

// ── Full-page settings (accessible from home) ─────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Expanded(child: _SettingsBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (ctx, theme, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DisplayModeSection(theme: theme),
          const SizedBox(height: 16),
          if (theme.displayMode == DisplayMode.custom)
            _CustomColorsSection(theme: theme),
          _BrightnessSection(theme: theme),
          const SizedBox(height: 16),
          _ReadingPrefsSection(theme: theme),
          const SizedBox(height: 16),
          _IsoNote(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Bottom sheet (accessible from reader) ─────────────────────────────────

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder),
            left: BorderSide(color: AppColors.cardBorder),
            right: BorderSide(color: AppColors.cardBorder),
          ),
        ),
        child: Consumer<ThemeProvider>(
          builder: (ctx, theme, _) => ListView(
            controller: scrollCtrl,
            padding:
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Reading Settings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _DisplayModeSection(theme: theme),
              const SizedBox(height: 14),
              if (theme.displayMode == DisplayMode.custom)
                _CustomColorsSection(theme: theme),
              _BrightnessSection(theme: theme),
              const SizedBox(height: 14),
              _ReadingPrefsSection(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Display mode selector ─────────────────────────────────────────────────

class _DisplayModeSection extends StatelessWidget {
  final ThemeProvider theme;

  const _DisplayModeSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Display Mode',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.05,
        children: DisplayMode.values
            .map((mode) => _ModeChip(
                  mode: mode,
                  theme: theme,
                  selected: theme.displayMode == mode,
                ))
            .toList(),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final DisplayMode mode;
  final ThemeProvider theme;
  final bool selected;

  const _ModeChip({
    required this.mode,
    required this.theme,
    required this.selected,
  });

  Color _bgFor(DisplayMode m) {
    switch (m) {
      case DisplayMode.light:
        return Colors.white;
      case DisplayMode.dark:
        return AppColors.darkBackground;
      case DisplayMode.amoledDark:
        return Colors.black;
      case DisplayMode.lowLight:
        return AppColors.lowLightBackground;
      case DisplayMode.night:
        return AppColors.nightBackground;
      case DisplayMode.custom:
        return theme.settings.customBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => theme.setDisplayMode(mode),
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: _bgFor(mode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.glowCyan,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              theme.displayModeIcon(mode),
              color: mode == DisplayMode.light
                  ? Colors.black54
                  : mode == DisplayMode.lowLight
                      ? AppColors.lowLightText
                      : mode == DisplayMode.night
                          ? AppColors.nightText
                          : AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              theme.displayModeName(mode),
              style: TextStyle(
                color: mode == DisplayMode.light
                    ? Colors.black87
                    : mode == DisplayMode.lowLight
                        ? AppColors.lowLightText
                        : mode == DisplayMode.night
                            ? AppColors.nightText
                            : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom colours ────────────────────────────────────────────────────────

class _CustomColorsSection extends StatelessWidget {
  final ThemeProvider theme;

  const _CustomColorsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Custom Colours',
      child: Column(
        children: [
          _ColorRow(
            label: 'Page background',
            color: theme.settings.customBackground,
            onTap: () async {
              final c = await ColorPickerSheet.show(
                context,
                initialColor: theme.settings.customBackground,
                title: 'Page Background Colour',
              );
              if (c != null) theme.setCustomBackground(c);
            },
          ),
          const SizedBox(height: 10),
          _ColorRow(
            label: 'Text / content tint',
            color: theme.settings.customForeground,
            onTap: () async {
              final c = await ColorPickerSheet.show(
                context,
                initialColor: theme.settings.customForeground,
                title: 'Content Tint Colour',
              );
              if (c != null) theme.setCustomForeground(c);
            },
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
          const Icon(Icons.edit_rounded,
              color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

// ── Brightness overlay ────────────────────────────────────────────────────

class _BrightnessSection extends StatelessWidget {
  final ThemeProvider theme;

  const _BrightnessSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Screen Brightness',
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.brightness_low_rounded,
                  color: AppColors.textSecondary, size: 18),
              Expanded(
                child: Slider(
                  value: theme.settings.brightnessOverlay,
                  min: 0.05,
                  max: 1.0,
                  divisions: 19,
                  activeColor: AppColors.cyan,
                  inactiveColor: AppColors.cardBorder,
                  onChanged: theme.setBrightnessOverlay,
                ),
              ),
              const Icon(Icons.brightness_high_rounded,
                  color: AppColors.cyan, size: 18),
            ],
          ),
          Text(
            'Tip: dim the screen for comfortable reading in the dark',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Reading preferences toggles ───────────────────────────────────────────

class _ReadingPrefsSection extends StatelessWidget {
  final ThemeProvider theme;

  const _ReadingPrefsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    final s = theme.settings;
    return _Section(
      title: 'Reading Preferences',
      child: Column(
        children: [
          _Toggle(
            icon: Icons.brightness_1_rounded,
            label: 'Keep screen on',
            subtitle: 'Prevents sleep while reading',
            value: s.keepScreenOn,
            onChanged: theme.setKeepScreenOn,
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _Toggle(
            icon: Icons.fullscreen_rounded,
            label: 'Open in full screen',
            subtitle: 'Hides status & nav bars',
            value: s.fullScreen,
            onChanged: theme.setFullScreen,
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _Toggle(
            icon: Icons.lock_rounded,
            label: 'Lock on open',
            subtitle: 'Enables reading lock automatically',
            value: s.touchLockOnOpen,
            onChanged: theme.setTouchLockOnOpen,
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          _ScrollDirectionPicker(theme: theme),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.cyan,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ],
    );
  }
}

class _ScrollDirectionPicker extends StatelessWidget {
  final ThemeProvider theme;

  const _ScrollDirectionPicker({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.swap_horiz_rounded,
                color: AppColors.cyan, size: 20),
            SizedBox(width: 12),
            Text(
              'Scroll direction',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DirChip(
                label: 'Vertical',
                icon: Icons.swap_vert_rounded,
                selected: theme.settings.scrollDirection ==
                    PageScrollDirection.vertical,
                onTap: () => theme.setScrollDirection(
                    PageScrollDirection.vertical),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DirChip(
                label: 'Horizontal',
                icon: Icons.swap_horiz_rounded,
                selected: theme.settings.scrollDirection ==
                    PageScrollDirection.horizontal,
                onTap: () => theme.setScrollDirection(
                    PageScrollDirection.horizontal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DirChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? AppColors.cyan
                    : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.cyan
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ISO compliance note ───────────────────────────────────────────────────

class _IsoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      glowColor: AppColors.green,
      pulsate: false,
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.green, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ISO 32000-2:2020 Compliant',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'PDF rendering via PDFium — the same engine used in Chrome — which implements PDF 2.0 (ISO 32000-2:2020) in full.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Shared section wrapper ────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
        ),
        GlowingCard(
          pulsate: false,
          child: child,
        ),
        const SizedBox(height: 4),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
