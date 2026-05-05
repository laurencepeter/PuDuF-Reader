class AppConstants {
  AppConstants._();

  static const String appName = 'PuDuF Reader';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Open Source · Ad-Free · ISO 32000-2:2020';

  // SharedPreferences keys
  static const String keyRecentFiles = 'recent_files';
  static const String keyReadingSettings = 'reading_settings';

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 2800);
  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animNormal = Duration(milliseconds: 320);
  static const Duration animSlow = Duration(milliseconds: 550);

  // Reader constraints
  static const double minZoom = 0.5;
  static const double maxZoom = 5.0;
  static const int maxRecentFiles = 30;

  // Touch-lock: fraction of screen height the user must swipe up to unlock
  static const double touchLockSwipeThreshold = 0.38;
}
