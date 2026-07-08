/// pure_native_splash is a build-time tool: run
/// `dart run pure_native_splash:create` to generate the Android and iOS
/// splash resources described by the `pure_native_splash:` section of your
/// `pubspec.yaml`. This library export exists so the config parser can be
/// unit tested and reused programmatically; app code does not need to
/// import it.
library;

export 'src/config.dart' show PureNativeSplashConfig;
