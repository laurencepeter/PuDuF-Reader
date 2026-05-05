import 'package:flutter/material.dart';

enum DisplayMode {
  light,
  dark,
  amoledDark,
  lowLight,
  night,
  custom,
}

enum PageScrollDirection {
  vertical,
  horizontal,
}

class ReadingSettings {
  final DisplayMode displayMode;
  final Color customBackground;
  final Color customForeground;
  final double brightnessOverlay; // 0.0 = full dim overlay, 1.0 = no overlay
  final bool keepScreenOn;
  final bool fullScreen;
  final bool touchLockOnOpen;
  final PageScrollDirection scrollDirection;

  const ReadingSettings({
    this.displayMode = DisplayMode.dark,
    this.customBackground = const Color(0xFFFFFFFF),
    this.customForeground = const Color(0xFF1A1A2E),
    this.brightnessOverlay = 1.0,
    this.keepScreenOn = true,
    this.fullScreen = false,
    this.touchLockOnOpen = false,
    this.scrollDirection = PageScrollDirection.vertical,
  });

  ReadingSettings copyWith({
    DisplayMode? displayMode,
    Color? customBackground,
    Color? customForeground,
    double? brightnessOverlay,
    bool? keepScreenOn,
    bool? fullScreen,
    bool? touchLockOnOpen,
    PageScrollDirection? scrollDirection,
  }) {
    return ReadingSettings(
      displayMode: displayMode ?? this.displayMode,
      customBackground: customBackground ?? this.customBackground,
      customForeground: customForeground ?? this.customForeground,
      brightnessOverlay: brightnessOverlay ?? this.brightnessOverlay,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      fullScreen: fullScreen ?? this.fullScreen,
      touchLockOnOpen: touchLockOnOpen ?? this.touchLockOnOpen,
      scrollDirection: scrollDirection ?? this.scrollDirection,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayMode': displayMode.index,
        'customBackground': customBackground.toARGB32(),
        'customForeground': customForeground.toARGB32(),
        'brightnessOverlay': brightnessOverlay,
        'keepScreenOn': keepScreenOn,
        'fullScreen': fullScreen,
        'touchLockOnOpen': touchLockOnOpen,
        'scrollDirection': scrollDirection.index,
      };

  factory ReadingSettings.fromJson(Map<String, dynamic> json) {
    return ReadingSettings(
      displayMode: DisplayMode.values[json['displayMode'] as int? ?? 1],
      customBackground:
          Color(json['customBackground'] as int? ?? 0xFFFFFFFF),
      customForeground:
          Color(json['customForeground'] as int? ?? 0xFF1A1A2E),
      brightnessOverlay: (json['brightnessOverlay'] as num?)?.toDouble() ?? 1.0,
      keepScreenOn: json['keepScreenOn'] as bool? ?? true,
      fullScreen: json['fullScreen'] as bool? ?? false,
      touchLockOnOpen: json['touchLockOnOpen'] as bool? ?? false,
      scrollDirection:
          PageScrollDirection.values[json['scrollDirection'] as int? ?? 0],
    );
  }
}
