# pure_native_splash

A tool for Flutter apps that draw their splash screen directly in Flutter, and just want the native splash to be a plain solid-color background with no logo.

## When to use this

- Apps that don't use a logo/animation on the native splash, and draw the loading screen themselves with Flutter widgets
- When you want to avoid a white flash, or (on Android 12+) a brief flash of the launcher icon, in between

## Setup

Add to `pubspec.yaml`:

```yaml
pure_native_splash:
  color: "#FFFFFF"        # Light-mode background color. Defaults to white if omitted
  color_dark: "#000000"   # Dark-mode background color. Defaults to black if omitted
```

Then run:

```sh
dart run pure_native_splash:create
```

It applies automatically to whichever of `android/`/`ios/` folders exist. If both exist, both are handled.

## Android 12+

Starting with Android 12, the OS forces the launcher icon onto the splash screen at app launch. Running this package prevents that automatically, with no extra configuration needed.

## License

MIT License — see the [LICENSE](LICENSE) file for details.

## Author

- Joseph88
- pathetic.sim@gmail.com
