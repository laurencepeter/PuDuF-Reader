import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdfrx/pdfrx.dart' show PdfOutlineNode;
import '../config/app_colors.dart';

class TocDrawer extends StatefulWidget {
  final List<PdfOutlineNode> outline;
  final int currentPage;
  final void Function(int page) onNavigate;
  final VoidCallback onClose;

  const TocDrawer({
    super.key,
    required this.outline,
    required this.currentPage,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  State<TocDrawer> createState() => _TocDrawerState();
}

class _TocDrawerState extends State<TocDrawer> {
  // Keys are "<title>:<pageNumber>" to uniquely identify expanded nodes
  final Set<String> _expanded = {};

  // Returns the page number of the deepest chapter that starts at or before
  // [currentPage], which is used to highlight the active entry.
  int? _activeChapterPage(
      List<PdfOutlineNode> nodes, int currentPage) {
    int? best;
    for (final node in nodes) {
      final p = node.dest?.pageNumber;
      if (p != null && p <= currentPage) {
        if (best == null || p > best) best = p;
      }
      final childBest =
          _activeChapterPage(node.children, currentPage);
      if (childBest != null && (best == null || childBest > best)) {
        best = childBest;
      }
    }
    return best;
  }

  String _nodeKey(PdfOutlineNode node) =>
      '${node.title}:${node.dest?.pageNumber ?? -1}';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final drawerWidth = mq.size.width * 0.78;
    final activePage =
        _activeChapterPage(widget.outline, widget.currentPage);

    return Stack(
      children: [
        // Scrim — tap to close
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
              color: Colors.black.withValues(alpha: 0.55)),
        ),

        // Drawer panel
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: drawerWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  right: BorderSide(
                    color: AppColors.cyan.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(8, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(mq),
                  const Divider(
                      height: 1, color: AppColors.cardBorder),
                  Expanded(
                      child: _buildList(activePage)),
                ],
              ),
            ),
          ).animate().slideX(
                begin: -1.0,
                end: 0,
                duration: 260.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
  }

  Widget _buildHeader(MediaQueryData mq) {
    return Padding(
      padding: EdgeInsets.only(
        top: mq.padding.top + 8,
        left: 16,
        right: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.cyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'CHAPTERS',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 2.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(int? activePage) {
    if (widget.outline.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chrome_reader_mode_outlined,
              size: 42,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No chapters found',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'This PDF has no table of contents',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: widget.outline
          .map((n) => _buildNode(n, 0, activePage))
          .toList(),
    );
  }

  Widget _buildNode(
      PdfOutlineNode node, int depth, int? activePage) {
    final page = node.dest?.pageNumber;
    final hasChildren = node.children.isNotEmpty;
    final key = _nodeKey(node);
    final isExpanded = _expanded.contains(key);
    final isActive =
        page != null && activePage != null && page == activePage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: page != null
              ? () {
                  widget.onNavigate(page);
                  widget.onClose();
                }
              : hasChildren
                  ? () => setState(() {
                        if (isExpanded) {
                          _expanded.remove(key);
                        } else {
                          _expanded.add(key);
                        }
                      })
                  : null,
          splashColor:
              AppColors.cyan.withValues(alpha: 0.08),
          highlightColor:
              AppColors.cyan.withValues(alpha: 0.04),
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + depth * 14.0,
              right: 12,
              top: 10,
              bottom: 10,
            ),
            decoration: isActive
                ? BoxDecoration(
                    border: const Border(
                      left: BorderSide(
                          color: AppColors.cyan, width: 3),
                    ),
                    color: AppColors.cyan
                        .withValues(alpha: 0.06),
                  )
                : null,
            child: Row(
              children: [
                if (hasChildren)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      isExpanded
                          ? Icons.expand_more_rounded
                          : Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    node.title,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.cyan
                          : depth == 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                      fontSize:
                          depth == 0 ? 13.5 : 12.5,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : depth == 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (page != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.cyan
                              .withValues(alpha: 0.18)
                          : AppColors.card,
                      borderRadius:
                          BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.cyan
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          ...node.children
              .map((child) =>
                  _buildNode(child, depth + 1, activePage))
              ,
      ],
    );
  }
}
