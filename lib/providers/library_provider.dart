import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/pdf_document.dart';

class LibraryProvider extends ChangeNotifier {
  List<PdfDocument> _recentFiles = [];
  bool _isLoading = false;

  List<PdfDocument> get recentFiles => List.unmodifiable(_recentFiles);
  bool get isLoading => _isLoading;
  bool get isEmpty => _recentFiles.isEmpty;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getStringList(AppConstants.keyRecentFiles) ?? [];

    _recentFiles = raw
        .map((s) {
          try {
            return PdfDocument.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<PdfDocument>()
        .where((doc) => File(doc.path).existsSync())
        .toList()
      ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdate(PdfDocument doc) async {
    _recentFiles.removeWhere((d) => d.path == doc.path);
    _recentFiles.insert(0, doc);

    if (_recentFiles.length > AppConstants.maxRecentFiles) {
      _recentFiles =
          _recentFiles.take(AppConstants.maxRecentFiles).toList();
    }

    await _persist();
    notifyListeners();
  }

  Future<void> remove(String path) async {
    _recentFiles.removeWhere((d) => d.path == path);
    await _persist();
    notifyListeners();
  }

  Future<void> updateLastPage(String path, int page, int totalPages) async {
    final idx = _recentFiles.indexWhere((d) => d.path == path);
    if (idx == -1) return;
    _recentFiles[idx] = _recentFiles[idx].copyWith(
      lastPage: page,
      totalPages: totalPages,
      lastOpened: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> toggleBookmark(String path, int page) async {
    final idx = _recentFiles.indexWhere((d) => d.path == path);
    if (idx == -1) return;
    final doc = _recentFiles[idx];
    final bookmarks = List<int>.from(doc.bookmarks);
    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
      bookmarks.sort();
    }
    _recentFiles[idx] = doc.copyWith(bookmarks: bookmarks);
    await _persist();
    notifyListeners();
  }

  PdfDocument? findByPath(String path) {
    try {
      return _recentFiles.firstWhere((d) => d.path == path);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      AppConstants.keyRecentFiles,
      _recentFiles.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }
}
