## 0.3.2

* Docs: README now opens with the problem it solves (the white flash at app
  launch) and a short feature list.
* pub.dev metadata: updated the package description and added the
  `native-splash` topic.
* Removed the author email from the README.

## 0.3.1

* `create` and `remove` now print a banner and step-by-step progress instead
  of a plain file list.

## 0.3.0

* Add `dart run pure_native_splash:remove`: restores the stock
  `flutter create` splash files and deletes everything this package
  generated. Files that no longer carry the generated marker (edited by
  hand or written by another tool) are left untouched and reported.
* The generated `LaunchScreen.storyboard` no longer contains the
  `LaunchImage` image view. On stock projects nothing changes visually
  (those images are blank), but on projects migrating from
  flutter_native_splash this stops the previous logo from reappearing
  on top of the splash color.
* An unquoted hex color (e.g. `color: #FFFFFF`, which YAML reads as an
  empty value plus a comment) is now a clear error suggesting quotes,
  instead of silently falling back to the default color.
* `create` now prints the `flutter clean` reminder only when it actually
  created new Android resource folders, and names them.

## 0.2.0

* Fix: the background color now applies on Android <12, not just 12+.
  Previously only the Android 12+ splash-screen APIs were themed via
  `values-v31`/`values-night-v31`; devices below API 31 kept the stock white
  background regardless of `pure_native_splash.color`. Fixed by generating
  `drawable/launch_background.xml`, `drawable-v21/launch_background.xml`,
  `drawable-night/launch_background.xml`, and
  `drawable-night-v21/launch_background.xml`.
* Add iOS support: generates `ios/Runner/Base.lproj/LaunchScreen.storyboard`
  and `ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json`
  for a solid-color light/dark-mode launch background.
* `color` and `color_dark` are now optional in `pure_native_splash:`; they
  default to `#FFFFFF` and `#000000` respectively when omitted. The
  `pure_native_splash:` section itself is still required.
* `dart run pure_native_splash:create` now writes to whichever of
  `android/`/`ios/` platform directories are present instead of requiring
  Android specifically; it only errors if neither is found.

## 0.1.0

* Initial release: `dart run pure_native_splash:create` sets the native
  Android splash background color and hides the Android 12+ launcher
  icon flash. No logo/branding support by design.
