import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/app_colors.dart';
import '../models/reading_settings.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/bookmarks_panel.dart';
import '../widgets/reader_controls.dart';
import '../widgets/toc_drawer.dart';
import '../widgets/touch_lock_overlay.dart';
import 'settings_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  final PdfViewerController _pdfController = PdfViewerController();

  // PDF outline (loaded once when the document is ready)
  List<PdfOutlineNode> _outline = [];

  // Panel visibility flags
  bool _isTocOpen = false;
  bool _isBookmarksPanelOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDisplayMode());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restoreSystemUI();
    WakelockPlus.disable();
    super.dispose();
  }

  // ── System UI helpers ─────────────────────────────────────────────────

  void _applyDisplayMode() {
    final settings = context.read<ThemeProvider>().settings;
    if (settings.keepScreenOn) WakelockPlus.enable();
    if (settings.fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      context.read<ReaderProvider>().setFullScreen(true);
    }
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleFullScreen(ReaderProvider reader) {
    final entering = !reader.isFullScreen;
    reader.setFullScreen(entering);
    if (entering) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // ── Outline loading ───────────────────────────────────────────────────

  Future<void> _loadOutline(PdfDocument document) async {
  try {
    final outline = await document.loadOutline();
    if (!mounted) return;

    setState(() {
      _outline = outline;
    });
  } catch (_) {
    // PDFs may not contain outlines — safe to ignore
  }
}

  // ── Page-jump dialog ──────────────────────────────────────────────────

  void _showJumpDialog(ReaderProvider reader) {
    final ctrl =
        TextEditingController(text: reader.currentPage.toString());
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Go to page (1–${reader.totalPages})',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Page number',
            hintStyle:
                const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.cyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final p = int.tryParse(ctrl.text);
              if (p != null &&
                  p >= 1 &&
                  p <= reader.totalPages) {
                _pdfController.goToPage(pageNumber: p);
              }
              Navigator.pop(context);
            },
            child: const Text('Go',
                style: TextStyle(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }

  // ── Settings sheet ────────────────────────────────────────────────────

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  // ── Bookmark helpers ──────────────────────────────────────────────────

  void _toggleBookmark() {
    final reader = context.read<ReaderProvider>();
    final library = context.read<LibraryProvider>();
    final path = reader.currentDocument?.path ?? '';
    library.toggleBookmark(path, reader.currentPage);
    final doc = library.findByPath(path);
    if (doc != null) reader.updateBookmarks(doc.bookmarks);
  }

  void _removeBookmark(int page) {
    final reader = context.read<ReaderProvider>();
    final library = context.read<LibraryProvider>();
    final path = reader.currentDocument?.path ?? '';
    // Only remove if it exists
    if (library.findByPath(path)?.bookmarks.contains(page) == true) {
      library.toggleBookmark(path, page);
      final doc = library.findByPath(path);
      if (doc != null) reader.updateBookmarks(doc.bookmarks);
    }
  }

  // ── Resume snackbar ───────────────────────────────────────────────────

  void _showResumeSnackbar(int page) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bookmark_rounded,
                color: AppColors.cyan, size: 16),
            const SizedBox(width: 8),
            Text(
              'Resuming from page $page',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReaderProvider, ThemeProvider>(
      builder: (_, reader, theme, __) {
        if (reader.currentDocument == null) {
          return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                  child: Text('No document',
                      style: TextStyle(
                          color: AppColors.textSecondary))));
        }

        // Close panels if lock is activated
        if (reader.isTouchLocked &&
            (_isTocOpen || _isBookmarksPanelOpen)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isTocOpen = false;
                _isBookmarksPanelOpen = false;
              });
            }
          });
        }

        final controlsVisible =
            reader.isControlsVisible && !reader.isTouchLocked;

        return Scaffold(
          backgroundColor: theme.pdfBackgroundColor,
          body: Stack(
            children: [
              // ── PDF viewer ──────────────────────────────────────
              _buildPdfViewer(reader, theme),

              // ── Brightness dim layer ────────────────────────────
              if (theme.settings.brightnessOverlay < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(
                          alpha:
                              1.0 - theme.settings.brightnessOverlay),
                    ),
                  ),
                ),

              // ── Tap-to-toggle-controls (only when unlocked) ─────
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: reader.isTouchLocked
                    ? null
                    : reader.toggleControls,
                child: const SizedBox.expand(),
              ),

              // ── Touch-lock overlay (transparent) ────────────────
              if (reader.isTouchLocked)
                Positioned.fill(
                  child: TouchLockOverlay(
                    onUnlock: () => reader.setTouchLocked(false),
                  ),
                ),

              // ── Top bar ─────────────────────────────────────────
              if (controlsVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ReaderTopBar(
                    onSettings: _openSettings,
                    onBookmark: _toggleBookmark,
                    onToc: () => setState(
                        () => _isTocOpen = !_isTocOpen),
                    onBookmarksList: () => setState(
                        () => _isBookmarksPanelOpen =
                            !_isBookmarksPanelOpen),
                  ),
                ),

              // ── Progress bar + bottom bar ────────────────────────
              if (controlsVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ReaderProgressBar(),
                      ReaderBottomBar(
                        onLock: () =>
                            reader.setTouchLocked(true),
                        onFullScreen: () =>
                            _toggleFullScreen(reader),
                        onJumpToPage: () =>
                            _showJumpDialog(reader),
                        onSettings: _openSettings,
                      ),
                    ],
                  ),
                ),

              // ── TOC drawer (slides from left) ────────────────────
              if (_isTocOpen && !reader.isTouchLocked)
                Positioned.fill(
                  child: TocDrawer(
                    outline: _outline,
                    currentPage: reader.currentPage,
                    onNavigate: (page) =>
                        _pdfController.goToPage(pageNumber: page),
                    onClose: () =>
                        setState(() => _isTocOpen = false),
                  ),
                ),

              // ── Bookmarks panel (slides from right) ──────────────
              if (_isBookmarksPanelOpen && !reader.isTouchLocked)
                Positioned.fill(
                  child: BookmarksPanel(
                    bookmarks: reader.bookmarks,
                    currentPage: reader.currentPage,
                    totalPages: reader.totalPages,
                    onNavigate: (page) =>
                        _pdfController.goToPage(pageNumber: page),
                    onRemove: _removeBookmark,
                    onClose: () => setState(
                        () => _isBookmarksPanelOpen = false),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfViewer(
      ReaderProvider reader, ThemeProvider theme) {
    final doc = reader.currentDocument!;
    final filter = theme.colorFilterMatrix;

    Widget viewer = PdfViewer.file(
      doc.path,
      controller: _pdfController,
      params: PdfViewerParams(
        backgroundColor: theme.pdfBackgroundColor,
        panAxis: theme.settings.scrollDirection ==
                PageScrollDirection.horizontal
            ? PanAxis.horizontal
            : PanAxis.vertical,
        onPageChanged: (page) {
          if (page == null) return;
          reader.onPageChanged(page);
          context.read<LibraryProvider>().updateLastPage(
                doc.path,
                page,
                reader.totalPages,
              );
        },
        onViewerReady: (document, _) {
          final total = document.pages.length;
          reader.onDocumentReady(total);

          // Load TOC outline
          _loadOutline(document);

          // Jump to last saved page and notify user
          if (doc.lastPage > 1) {
            Future.microtask(() {
              _pdfController.goToPage(pageNumber: doc.lastPage);
              _showResumeSnackbar(doc.lastPage);
            });
          }
        },
        pageDropShadow: null,
      ),
    );

    if (filter != null) {
      viewer = ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: viewer,
      );
    }

    return Positioned.fill(child: viewer);
  }
}
