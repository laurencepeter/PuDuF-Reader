# PuDuF Reader

**Open Source · Ad-Free · ISO 32000-2:2020**

A futuristic PDF reader for Android built with Flutter. No ads, no tracking, no subscriptions — just clean, fast reading.

## Features

**Reading**
- Powered by PDFium (the same engine as Chrome) — fully ISO 32000-2:2020 / PDF 2.0 compliant
- Resumes from your last page automatically
- Pinch-to-zoom (0.5× – 5×)
- Vertical or horizontal scroll direction
- Jump to any page instantly
- Full-screen immersive mode (hides status and navigation bars)
- Keep-screen-on wakelock so your display never sleeps mid-read

**Library**
- Recent files grid with reading progress shown per document
- Per-document bookmarks with visual indicators
- Long-press context menu to open, share, or remove files

**Display & Comfort**
- Six display modes: Light, Dark, AMOLED Dark, Low Light, Night, and fully Custom
- Custom colour picker for page background and content tint
- In-app brightness overlay for comfortable reading in the dark
- Touch lock — lock the screen against accidental taps; swipe up to unlock

**Design**
- Glowing cyan/purple futuristic UI built entirely in Flutter
- Smooth enter/exit animations on every screen and card

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3 / Dart |
| PDF engine | [pdfrx](https://pub.dev/packages/pdfrx) (PDFium) |
| State | Provider |
| Storage | shared_preferences |
| Fonts | Google Fonts |
| Animations | flutter_animate |
| File picker | file_picker |
| Share | share_plus |
| Wakelock | wakelock_plus |

## Getting Started

**Requirements:** Flutter SDK ≥ 3.4.0, Android SDK (minSdk 21)

```bash
git clone https://github.com/laurencepeter/puduf-reader.git
cd puduf-reader
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

## License

This project is open source. See [LICENSE](LICENSE) for details.
