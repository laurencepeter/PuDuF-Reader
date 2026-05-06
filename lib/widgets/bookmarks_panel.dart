import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';

class BookmarksPanel extends StatelessWidget {
  final List<int> bookmarks;
  final int currentPage;
  final int totalPages;
  final void Function(int page) onNavigate;
  final void Function(int page) onRemove;
  final VoidCallback onClose;

  const BookmarksPanel({
    super.key,
    required this.bookmarks,
    required this.currentPage,
    required this.totalPages,
    required this.onNavigate,
    required this.onRemove,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final panelWidth = mediaQuery.size.width * 0.78;
    final sorted = [...bookmarks]..sort();

    return Stack(
      children: [
        // Scrim
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.55)),
        ),

        // Panel — slides in from the right
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: panelWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  left: BorderSide(
                    color: AppColors.orange.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(-8, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(mediaQuery, sorted.length),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  Expanded(child: _buildList(sorted)),
                ],
              ),
            ),
          ).animate().slideX(begin: 1.0, end: 0, duration: 260.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  Widget _buildHeader(MediaQueryData mq, int count) {
    return Padding(
      padding: EdgeInsets.only(
        top: mq.padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'BOOKMARKS',
              style: TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 2.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<int> sorted) {
    if (sorted.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmarks_outlined,
              size: 42,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No bookmarks yet',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the bookmark icon while reading\nto save a page',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (_, i) => _buildItem(sorted[i]),
    );
  }

  Widget _buildItem(int page) {
    final isCurrent = page == currentPage;
    final progress = totalPages > 0 ? page / totalPages : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.orange.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppColors.orange : AppColors.cardBorder,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onNavigate(page);
            onClose();
          },
          splashColor: AppColors.orange.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Bookmark icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.orange.withValues(alpha: 0.2)
                        : AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.orange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // Page info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page $page',
                        style: TextStyle(
                          color: isCurrent
                              ? AppColors.orange
                              : AppColors.textPrimary,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.cardBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCurrent
                                ? AppColors.orange
                                : AppColors.orange.withValues(alpha: 0.5),
                          ),
                          minHeight: 3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% through document',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: () => onRemove(page),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
