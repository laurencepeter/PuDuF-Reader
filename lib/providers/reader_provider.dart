import 'package:flutter/foundation.dart';
import '../models/pdf_document.dart';

class ReaderProvider extends ChangeNotifier {
  PdfDocument? _currentDocument;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isControlsVisible = true;
  bool _isTouchLocked = false;
  bool _isFullScreen = false;

  PdfDocument? get currentDocument => _currentDocument;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isControlsVisible => _isControlsVisible;
  bool get isTouchLocked => _isTouchLocked;
  bool get isFullScreen => _isFullScreen;

  List<int> get bookmarks =>
      _currentDocument?.bookmarks ?? const [];

  bool get isCurrentPageBookmarked =>
      bookmarks.contains(_currentPage);

  double get readingProgress =>
      _totalPages > 0 ? _currentPage / _totalPages : 0.0;

  void openDocument(PdfDocument doc, {bool lockOnOpen = false}) {
    _currentDocument = doc;
    _currentPage = doc.lastPage.clamp(1, doc.totalPages > 0 ? doc.totalPages : doc.lastPage);
    _isControlsVisible = true;
    _isTouchLocked = lockOnOpen;
    notifyListeners();
  }

  void onPageChanged(int page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  void onDocumentReady(int totalPages) {
    _totalPages = totalPages;
    notifyListeners();
  }

  void toggleControls() {
    _isControlsVisible = !_isControlsVisible;
    notifyListeners();
  }

  void showControls() {
    if (!_isControlsVisible) {
      _isControlsVisible = true;
      notifyListeners();
    }
  }

  void setTouchLocked(bool locked) {
    if (_isTouchLocked == locked) return;
    _isTouchLocked = locked;
    notifyListeners();
  }

  void setFullScreen(bool fullScreen) {
    if (_isFullScreen == fullScreen) return;
    _isFullScreen = fullScreen;
    notifyListeners();
  }

  void updateBookmarks(List<int> bookmarks) {
    if (_currentDocument == null) return;
    _currentDocument = _currentDocument!.copyWith(bookmarks: bookmarks);
    notifyListeners();
  }

  void close() {
    _currentDocument = null;
    _currentPage = 1;
    _totalPages = 0;
    _isControlsVisible = true;
    _isTouchLocked = false;
    _isFullScreen = false;
    notifyListeners();
  }
}
