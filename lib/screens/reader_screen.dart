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
import '../widgets/reader_controls.dart';
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
  final bool _controlsVisible = true;

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
    final settings =
        context.read<ThemeProvider>().settings;
    if (settings.keepScreenOn) WakelockPlus.enable();
    if (settings.fullScreen) {
      SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky);
      context.read<ReaderProvider>().setFullScreen(true);
    }
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge);
  }

  void _toggleFullScreen(ReaderProvider reader) {
    final entering = !reader.isFullScreen;
    reader.setFullScreen(entering);
    if (entering) {
      SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge);
    }
  }

  // ── Page-jump dialog ──────────────────────────────────────────────────

  void _showJumpDialog(ReaderProvider reader) {
    final ctrl = TextEditingController(
        text: reader.currentPage.toString());
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
                style: TextStyle(color: AppColors.textSecondary)),
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

  // ── Bookmark ──────────────────────────────────────────────────────────

  void _toggleBookmark() {
    final reader = context.read<ReaderProvider>();
    final library = context.read<LibraryProvider>();
    final path = reader.currentDocument?.path ?? '';
    library.toggleBookmark(path, reader.currentPage);

    final doc = library.findByPath(path);
    if (doc != null) {
      reader.updateBookmarks(doc.bookmarks);
    }
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

        return Scaffold(
          backgroundColor: theme.pdfBackgroundColor,
          body: Stack(
            children: [
              // PDF viewer (with optional colour filter)
              _buildPdfViewer(reader, theme),

              // Brightness overlay (dim layer)
              if (theme.settings.brightnessOverlay < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(
                          alpha: 1.0 -
                              theme.settings.brightnessOverlay),
                    ),
                  ),
                ),

              // Touch-lock overlay
              if (reader.isTouchLocked)
                Positioned.fill(
                  child: TouchLockOverlay(
                    onUnlock: () =>
                        reader.setTouchLocked(false),
                  ),
                ),

              // Tap-to-toggle-controls (pass-through)
              if (!reader.isTouchLocked)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: reader.toggleControls,
                  child: const SizedBox.expand(),
                ),

              // Top bar
              if (_controlsVisible && !reader.isTouchLocked)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ReaderTopBar(
                    onSettings: _openSettings,
                    onBookmark: _toggleBookmark,
                  ),
                ),

              // Progress + bottom bar
              if (_controlsVisible && !reader.isTouchLocked)
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
          // Persist progress to library
          context.read<LibraryProvider>().updateLastPage(
                doc.path,
                page,
                reader.totalPages,
              );
        },
        onViewerReady: (document, _) {
          final total = document.pages.length;
          reader.onDocumentReady(total);
          // Jump to last saved page
          if (doc.lastPage > 1) {
            Future.microtask(() => _pdfController.goToPage(
                pageNumber: doc.lastPage));
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
