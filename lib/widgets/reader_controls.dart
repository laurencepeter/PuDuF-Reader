import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/reader_provider.dart';

class ReaderTopBar extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onBookmark;

  const ReaderTopBar({
    super.key,
    required this.onSettings,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (_, reader, __) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          left: 12,
          right: 12,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withOpacity(0.96),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            _IconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reader.currentDocument?.displayName ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _IconBtn(
              icon: reader.isCurrentPageBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: reader.isCurrentPageBookmarked
                  ? AppColors.orange
                  : null,
              onTap: onBookmark,
            ),
            const SizedBox(width: 4),
            _IconBtn(
              icon: Icons.tune_rounded,
              onTap: onSettings,
            ),
          ],
        ),
      ).animate().slideY(begin: -0.15, end: 0, duration: 220.ms).fadeIn(duration: 220.ms),
    );
  }
}

class ReaderProgressBar extends StatelessWidget {
  const ReaderProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (_, reader, __) => Container(
        height: 3,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor:
              reader.readingProgress.clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReaderBottomBar extends StatelessWidget {
  final VoidCallback onLock;
  final VoidCallback onFullScreen;
  final VoidCallback onJumpToPage;
  final VoidCallback onSettings;

  const ReaderBottomBar({
    super.key,
    required this.onLock,
    required this.onFullScreen,
    required this.onJumpToPage,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (_, reader, __) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 6,
          left: 16,
          right: 16,
          top: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.background.withOpacity(0.97),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomBtn(
              icon: Icons.lock_outline_rounded,
              label: 'Lock',
              onTap: onLock,
            ),
            _BottomBtn(
              icon: reader.isFullScreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              label: reader.isFullScreen ? 'Exit' : 'Full',
              onTap: onFullScreen,
            ),
            _PageCounter(onTap: onJumpToPage, reader: reader),
            _BottomBtn(
              icon: Icons.format_list_numbered_rounded,
              label: 'Go to',
              onTap: onJumpToPage,
            ),
            _BottomBtn(
              icon: Icons.brightness_6_rounded,
              label: 'Theme',
              onTap: onSettings,
            ),
          ],
        ),
      ).animate().slideY(begin: 0.15, end: 0, duration: 220.ms).fadeIn(duration: 220.ms),
    );
  }
}

// ── Reusable icon buttons ─────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon,
            size: 20, color: color ?? AppColors.textPrimary),
      ),
    );
  }
}

class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 21),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  final VoidCallback onTap;
  final ReaderProvider reader;

  const _PageCounter({required this.onTap, required this.reader});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowCyan,
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${reader.currentPage}',
              style: const TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              ' / ${reader.totalPages}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
