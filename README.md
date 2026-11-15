# pure_native_splash

Removes the white flash at app launch. A solid-color native splash for Flutter apps that draw their own splash screen in Flutter.

<!--
TODO: add the before/after GIF, then uncomment (publish only after the file exists):
![Before and after on iOS](https://raw.githubusercontent.com/joseph-seph88/pure_native_splash/main/doc/before_after.gif)
*Left: image-view launch screen (white flash). Right: pure_native_splash. Real iPhone, release build, slow motion.*
-->

- **Solid color only** — no logo, no image view.
- **iOS:** no white flash before your first Flutter frame (checked on a real device, release build).
- **Android:** 11 and below, and 12+ (hides the launcher-icon flash).
- **Light & dark mode.**
- **One command to apply, one to undo.**
- **Leaves `Info.plist` and `project.pbxproj` untouched.**

## When to use this

Use it if your app doesn't put a logo or animation on the native splash, and draws the loading screen itself with Flutter widgets. If you want a logo on the native splash, this package is not for you.

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
