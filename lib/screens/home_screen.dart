import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_colors.dart';
import '../config/constants.dart';
import '../models/pdf_document.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/glowing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPickingFile = false;

  // ── File picker ───────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        await _openPdf(path, name);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Future<void> _openPdf(String path, String name) async {
    final library = context.read<LibraryProvider>();
    final existing = library.findByPath(path);
    final doc = existing ??
        PdfDocument(
          path: path,
          name: name,
          lastOpened: DateTime.now(),
        );

    final updated = doc.copyWith(lastOpened: DateTime.now());
    await library.addOrUpdate(updated);

    if (!mounted) return;
    context.read<ReaderProvider>().openDocument(
          updated,
          lockOnOpen:
              context.read<ThemeProvider>().settings.touchLockOnOpen,
        );
    Navigator.pushNamed(context, '/reader');
  }

  Future<void> _sharePdf(PdfDocument doc) async {
    await Share.shareXFiles([XFile(doc.path)], text: doc.displayName);
  }

  void _confirmDelete(PdfDocument doc) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove from library?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This removes "${doc.displayName}" from recents.\nThe original file is not deleted.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LibraryProvider>().remove(doc.path);
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(onSettings: _goToSettings),
              Expanded(
                child: Consumer<LibraryProvider>(
                  builder: (_, library, __) {
                    if (library.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.cyan),
                      );
                    }
                    if (library.isEmpty) {
                      return _EmptyState(onOpen: _pickFile);
                    }
                    return _FileGrid(
                      documents: library.recentFiles,
                      onOpen: (doc) =>
                          _openPdf(doc.path, doc.name),
                      onShare: _sharePdf,
                      onDelete: _confirmDelete,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _OpenFab(
        isLoading: _isPickingFile,
        onPressed: _pickFile,
      ),
    );
  }

  void _goToSettings() =>
      Navigator.pushNamed(context, '/settings');
}

// ── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onSettings;

  const _Header({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purpleLight],
                ).createShader(b),
                child: const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSettings,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.textPrimary, size: 22),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
    );
  }
}

// ── File grid ─────────────────────────────────────────────────────────────

class _FileGrid extends StatelessWidget {
  final List<PdfDocument> documents;
  final ValueChanged<PdfDocument> onOpen;
  final ValueChanged<PdfDocument> onShare;
  final ValueChanged<PdfDocument> onDelete;

  const _FileGrid({
    required this.documents,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: documents.length,
      itemBuilder: (_, i) => _FileCard(
        doc: documents[i],
        onOpen: onOpen,
        onShare: onShare,
        onDelete: onDelete,
      )
          .animate(delay: (i * 40).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.12, end: 0, duration: 350.ms),
    );
  }
}

class _FileCard extends StatelessWidget {
  final PdfDocument doc;
  final ValueChanged<PdfDocument> onOpen;
  final ValueChanged<PdfDocument> onShare;
  final ValueChanged<PdfDocument> onDelete;

  const _FileCard({
    required this.doc,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      padding: EdgeInsets.zero,
      glowColor: doc.bookmarks.isNotEmpty
          ? AppColors.orange
          : AppColors.cyan,
      onTap: () => onOpen(doc),
      onLongPress: () => _showActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail / icon area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 56,
                    color: AppColors.cyan.withValues(alpha: 0.35),
                  ),
                  if (doc.bookmarks.isNotEmpty)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.bookmark_rounded,
                          color: AppColors.orange, size: 18),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(doc.readingProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Progress bar
          LinearProgressIndicator(
            value: doc.readingProgress,
            backgroundColor: AppColors.cardBorder,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.cyan),
            minHeight: 2,
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _timeAgo(doc.lastOpened),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                doc.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded,
                  color: AppColors.cyan),
              title: const Text('Open',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                onOpen(doc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded,
                  color: AppColors.green),
              title: const Text('Share',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                onShare(doc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.red),
              title: const Text('Remove from library',
                  style: TextStyle(color: AppColors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete(doc);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onOpen;

  const _EmptyState({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            size: 80,
            color: AppColors.textMuted,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms,
                  curve: Curves.easeInOut),
          const SizedBox(height: 24),
          const Text(
            'No PDFs yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 10),
          const Text(
            'Tap the button below to open your\nfirst PDF document.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 40),
          FuturisticButton(
            label: 'OPEN PDF',
            icon: Icons.folder_open_rounded,
            onPressed: onOpen,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────

class _OpenFab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _OpenFab({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.cyan, AppColors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowCyan,
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Icon(Icons.add_rounded,
                color: Colors.white, size: 30),
      ),
    );
  }
}
