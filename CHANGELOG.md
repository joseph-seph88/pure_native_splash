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
