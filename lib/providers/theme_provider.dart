import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/constants.dart';
import '../models/reading_settings.dart';

class ThemeProvider extends ChangeNotifier {
  ReadingSettings _settings = const ReadingSettings();
  bool _isLoaded = false;

  ReadingSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  DisplayMode get displayMode => _settings.displayMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyReadingSettings);
    if (raw != null) {
      try {
        _settings = ReadingSettings.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _settings = const ReadingSettings();
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.keyReadingSettings, jsonEncode(_settings.toJson()));
  }

  Future<void> setDisplayMode(DisplayMode mode) async {
    _settings = _settings.copyWith(displayMode: mode);
    await _save();
    notifyListeners();
  }

  Future<void> setCustomBackground(Color color) async {
    _settings = _settings.copyWith(customBackground: color);
    await _save();
    notifyListeners();
  }

  Future<void> setCustomForeground(Color color) async {
    _settings = _settings.copyWith(customForeground: color);
    await _save();
    notifyListeners();
  }

  Future<void> setBrightnessOverlay(double value) async {
    _settings =
        _settings.copyWith(brightnessOverlay: value.clamp(0.05, 1.0));
    await _save();
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
    _settings = _settings.copyWith(keepScreenOn: value);
    await _save();
    notifyListeners();
  }

  Future<void> setFullScreen(bool value) async {
    _settings = _settings.copyWith(fullScreen: value);
    await _save();
    notifyListeners();
  }

  Future<void> setTouchLockOnOpen(bool value) async {
    _settings = _settings.copyWith(touchLockOnOpen: value);
    await _save();
    notifyListeners();
  }

  Future<void> setScrollDirection(PageScrollDirection dir) async {
    _settings = _settings.copyWith(scrollDirection: dir);
    await _save();
    notifyListeners();
  }

  // ── Color filter matrix for the current display mode ──────────────────
  List<double>? get colorFilterMatrix {
    switch (_settings.displayMode) {
      case DisplayMode.dark:
      case DisplayMode.amoledDark:
        // Invert colours so white PDFs become dark
        return const [
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ];
      case DisplayMode.lowLight:
        // Warm sepia — like Kindle Paperwhite
        return const [
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0,     0,     0,     1, 0,
        ];
      case DisplayMode.night:
        // Deep red filter for night-vision / darkness reading
        return const [
          0.8,  0,   0, 0, 20,
          0,    0.1, 0, 0,  0,
          0,    0,   0, 0,  0,
          0,    0,   0, 1,  0,
        ];
      case DisplayMode.light:
      case DisplayMode.custom:
        return null;
    }
  }

  Color get pdfBackgroundColor {
    switch (_settings.displayMode) {
      case DisplayMode.light:
        return AppColors.lightBackground;
      case DisplayMode.dark:
        return AppColors.darkBackground;
      case DisplayMode.amoledDark:
        return AppColors.amoledBackground;
      case DisplayMode.lowLight:
        return AppColors.lowLightBackground;
      case DisplayMode.night:
        return AppColors.nightBackground;
      case DisplayMode.custom:
        return _settings.customBackground;
    }
  }

  String displayModeName(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.light:
        return 'Light';
      case DisplayMode.dark:
        return 'Dark';
      case DisplayMode.amoledDark:
        return 'AMOLED';
      case DisplayMode.lowLight:
        return 'Low Light';
      case DisplayMode.night:
        return 'Night';
      case DisplayMode.custom:
        return 'Custom';
    }
  }

  String displayModeDescription(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.light:
        return 'Standard white background';
      case DisplayMode.dark:
        return 'Inverted dark navy';
      case DisplayMode.amoledDark:
        return 'True black — saves battery';
      case DisplayMode.lowLight:
        return 'Warm sepia — Kindle style';
      case DisplayMode.night:
        return 'Red filter for total darkness';
      case DisplayMode.custom:
        return 'Your own colour palette';
    }
  }

  IconData displayModeIcon(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.light:
        return Icons.light_mode_rounded;
      case DisplayMode.dark:
        return Icons.dark_mode_rounded;
      case DisplayMode.amoledDark:
        return Icons.circle_rounded;
      case DisplayMode.lowLight:
        return Icons.nightlight_round;
      case DisplayMode.night:
        return Icons.remove_red_eye_rounded;
      case DisplayMode.custom:
        return Icons.palette_rounded;
    }
  }
}
