A minimal native splash setup for Flutter apps.

This package does exactly two things:

1. Sets the native Android splash screen background color.
2. Prevents Android 12+ from flashing your launcher icon on the splash
   screen (by pointing `windowSplashScreenAnimatedIcon` at a transparent
   1dp drawable).

That's it. No logo images, no branding, no animated icons, and no iOS
changes (iOS doesn't have this launcher-icon-flash issue in the first
place). If you need a logo/branding splash, use
[`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)
instead — this package intentionally does not grow into that.

## Setup

Add the dev dependency:

```yaml
dev_dependencies:
  pure_native_splash: ^0.1.0
```

Configure it, also in `pubspec.yaml`:

```yaml
pure_native_splash:
  color: "#FFFFFF"        # required. Light-mode background color.
  color_dark: "#000000"   # optional. Defaults to `color` if omitted.
```

Colors must be hex, either `#RRGGBB` or `#AARRGGBB`.

## Run

```sh
dart run pure_native_splash:create
```

This generates/overwrites 3 files under `android/app/src/main/res/`:

- `drawable/splash_icon_blank.xml`
- `values-v31/styles.xml`
- `values-night-v31/styles.xml`

If any of those `values-*` folders are being created for the first time,
run `flutter clean` once before your next build — Gradle's incremental
build can otherwise miss brand-new resource qualifiers.

## Ownership of generated files

The 3 files above are considered fully owned by this package: every run
of `create` overwrites them from scratch based on your current config.
Don't hand-edit them — hand edits will silently disappear on the next
run. This is a deliberate tradeoff to avoid the "regenerate silently
drops my manual override" class of bugs.

## Out of scope

- Logo/branding images, animated icons
- iOS customization
- Integration with `flutter_launcher_icons`
