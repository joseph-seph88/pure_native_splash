# pure_native_splash

A tool for Flutter apps that draw their splash screen directly in Flutter, and just want the native splash to be a plain solid-color background with no logo.

## When to use this

- Apps that don't use a logo/animation on the native splash, and draw the loading screen themselves with Flutter widgets
- When you want to avoid a white flash, or (on Android 12+) a brief flash of the launcher icon — handled automatically, no extra configuration

## Setup

Add to `pubspec.yaml`:

```yaml
pure_native_splash:
  color: "#FFFFFF" # Hex only (#RRGGBB or #AARRGGBB). Quotes required — unquoted # starts a YAML comment
  color_dark: "#000000" # Optional. Falls back to `color`, or black if both omitted
```

Then run:

```sh
dart run pure_native_splash:create
```

## Removing

To restore the stock Flutter splash files and delete everything this package generated:

```sh
dart run pure_native_splash:remove
```

Files you have edited by hand are left untouched.

## Migrating from flutter_native_splash

If you are migrating from `flutter_native_splash`, run its cleanup before removing it from `pubspec.yaml`, so the splash images it generated get deleted:

```sh
dart run flutter_native_splash:remove
```

Even if you skip this, this package still works fine — you would just need to delete the previously generated images manually.

## Limitations

- Assumes the stock `flutter create` project layout; only `android/app/src/main/res` is written — flavor-specific resources (`src/<flavor>/res`) are not supported.
- Android and iOS only; web and desktop are out of scope.

## License

MIT License — see the [LICENSE](LICENSE) file for details.

## Author

- Joseph88
- pathetic.sim@gmail.com