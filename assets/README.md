# PuDuF Reader — Branding assets

Production icon sheet. Folders mirror the Flutter project layout — copy them
into your project root and they land in the right places.

| Path | Purpose |
|---|---|
| assets/branding/icon.png | 1024 master, dark, no alpha (App Store + flutter_launcher_icons source) |
| assets/branding/icon-maskable.png | 1024 PWA-maskable master, full-bleed |
| assets/branding/icon-foreground.png | 1024 transparent foreground for Android adaptive |
| web/favicon.png | 16x16 compact mark — browser tab |
| web/icons/Icon-{192,512}.png | PWA standard |
| web/icons/Icon-maskable-{192,512}.png | PWA maskable |
| web/manifest.json | Manifest with theme color and icon entries |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/ | All iOS sizes + Contents.json |
| android/app/src/main/res/mipmap-*/ | Legacy ic_launcher + adaptive foreground |
| android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml | Adaptive descriptor |
| android/app/src/main/res/values/ic_launcher_colors.xml | #080C1A background |
| flutter_launcher_icons.yaml | Regenerate everything from one command |

## Wire it up
1. pubspec.yaml:
   flutter:
     assets:
       - assets/branding/
2. web/index.html head:
   <link rel="icon" type="image/png" href="favicon.png"/>
   <link rel="apple-touch-icon" href="icons/Icon-192.png"/>
   <meta name="theme-color" content="#080C1A">
3. Optional regenerate:
   dart pub add --dev flutter_launcher_icons
   dart run flutter_launcher_icons

Note: iOS filenames use '-1x/-2x/-3x' instead of Apple's '@1x/@2x/@3x'
because the source filesystem disallows '@' in paths. Contents.json points
to these names; Xcode reads filenames from the manifest, so it works fine.
If you prefer Apple's exact convention, batch-rename and update Contents.json:
  for f in *-1x*.png; do mv "$f" "${f/-1x/@1x}"; done   (and 2x/3x)
