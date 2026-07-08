import 'package:file/file.dart';

import 'config.dart';
import 'generated_notice.dart';

/// Writes the fixed set of Android resource files this package owns:
/// a transparent 1dp drawable (suppresses the Android 12+ launcher-icon
/// flash), solid-color `launch_background.xml` drawables across the
/// `drawable`/`drawable-v21`/`drawable-night`/`drawable-night-v21`
/// qualifiers (covers the background color on API <31), and
/// `values-v31`/`values-night-v31` `styles.xml` overrides that point
/// `LaunchTheme`'s splash-screen icon at the blank drawable and set the
/// Android 12+ splash-screen background color directly.
///
/// This package deliberately never opens `values/styles.xml` or
/// `values-night/styles.xml` — both also define an unrelated `NormalTheme`
/// style that must survive untouched. Full pre-12 color coverage is
/// achieved instead by taking ownership of `drawable/launch_background.xml`
/// (and its qualifier variants), which is what those files' existing
/// `LaunchTheme.windowBackground` already points at in a stock `flutter
/// create` project.
///
/// The `parent` used for each `-v31` override (`Theme.Light.NoTitleBar` for
/// `values-v31`, `Theme.Black.NoTitleBar` for `values-night-v31`) matches
/// what `flutter create`'s default Android template puts in
/// `values/styles.xml` and `values-night/styles.xml` respectively. Using
/// anything else (e.g. a `.Fullscreen` variant) would make the Android
/// 12+ splash behave differently from <12 — e.g. hiding the status bar
/// only on 12+ — even though nothing else about the app changed.
class AndroidSplashWriter {
  AndroidSplashWriter(this.fs, this.projectRoot);

  final FileSystem fs;
  final String projectRoot;

  String get _androidDir => fs.path.join(projectRoot, 'android');

  String get _resDir => fs.path.join(_androidDir, 'app', 'src', 'main', 'res');

  /// Whether this looks like a Flutter project with the Android platform
  /// added (i.e. has an `android/` folder to write into).
  bool get hasAndroidPlatform => fs.directory(_androidDir).existsSync();

  /// Writes all 7 files for [config], always overwriting prior contents.
  /// Returns the absolute paths written, in a fixed order.
  List<String> write(PureNativeSplashConfig config) {
    return <String>[
      _writeBlankDrawable(),
      _writeLaunchBackground(qualifier: 'drawable', color: config.color),
      _writeLaunchBackground(qualifier: 'drawable-v21', color: config.color),
      _writeLaunchBackground(
        qualifier: 'drawable-night',
        color: config.colorDark,
      ),
      _writeLaunchBackground(
        qualifier: 'drawable-night-v21',
        color: config.colorDark,
      ),
      _writeStyles(
        qualifier: 'values-v31',
        color: config.color,
        parent: '@android:style/Theme.Light.NoTitleBar',
      ),
      _writeStyles(
        qualifier: 'values-night-v31',
        color: config.colorDark,
        parent: '@android:style/Theme.Black.NoTitleBar',
      ),
    ];
  }

  String _writeBlankDrawable() => _writeShapeDrawable(
    qualifier: 'drawable',
    fileName: 'splash_icon_blank.xml',
    color: '#00000000',
    sizeXml: '\n    <size android:width="1dp" android:height="1dp" />',
  );

  String _writeLaunchBackground({
    required String qualifier,
    required String color,
  }) => _writeShapeDrawable(
    qualifier: qualifier,
    fileName: 'launch_background.xml',
    color: color,
  );

  String _writeShapeDrawable({
    required String qualifier,
    required String fileName,
    required String color,
    String sizeXml = '',
  }) {
    final file = fs.file(fs.path.join(_resDir, qualifier, fileName));
    file.createSync(recursive: true);
    file.writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
$generatedNoticeXmlComment
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="$color" />$sizeXml
</shape>
''');
    return file.path;
  }

  String _writeStyles({
    required String qualifier,
    required String color,
    required String parent,
  }) {
    final file = fs.file(fs.path.join(_resDir, qualifier, 'styles.xml'));
    file.createSync(recursive: true);
    file.writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
$generatedNoticeXmlComment
<resources>
    <style name="LaunchTheme" parent="$parent">
        <item name="android:windowSplashScreenBackground">$color</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/splash_icon_blank</item>
        <item name="android:windowSplashScreenIconBackgroundColor">$color</item>
    </style>
</resources>
''');
    return file.path;
  }
}
