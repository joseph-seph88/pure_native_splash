import 'package:file/file.dart';
import 'config.dart';
import 'generated_notice.dart';
import 'remove_result.dart';
import 'stock_templates.dart';

/// Writes the Android resources this package owns: solid-color
/// `launch_background.xml` drawables (the background on API <31) and
/// `values-v31`/`values-night-v31` `styles.xml` overrides that set the
/// Android 12+ splash background and point its icon at a transparent 1dp
/// drawable, suppressing the forced launcher-icon flash.
///
/// `values/styles.xml`/`values-night/styles.xml` are deliberately never
/// opened — they also define an unrelated `NormalTheme` that must survive.
/// Pre-12 coverage comes from owning `drawable/launch_background.xml`
/// instead, which is what their `LaunchTheme.windowBackground` already
/// points at in a stock project.
///
/// Each `-v31` override's `parent` matches what the stock template uses
/// for the same mode; anything else (e.g. a `.Fullscreen` variant) would
/// make the splash behave differently on 12+ than below it.
class AndroidSplashWriter {
  AndroidSplashWriter(this.fs, this.projectRoot);

  final FileSystem fs;
  final String projectRoot;

  String get _androidDir => fs.path.join(projectRoot, 'android');

  String get _resDir => fs.path.join(_androidDir, 'app', 'src', 'main', 'res');

  bool get hasAndroidPlatform => fs.directory(_androidDir).existsSync();

  /// Introduced qualifier folders that don't exist yet, i.e. the ones the
  /// next [write] will create for the first time. Gradle's incremental
  /// build can miss brand-new resource qualifiers, so the CLI tells the
  /// user to `flutter clean` when this is non-empty.
  List<String> get missingIntroducedQualifiers => [
        for (final qualifier in _introducedQualifiers)
          if (!fs.directory(fs.path.join(_resDir, qualifier)).existsSync())
            qualifier,
      ];

  /// Always overwrites prior contents; returns the paths written.
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
  }) =>
      _writeShapeDrawable(
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

  /// Restores the stock files this package overwrote and deletes the ones
  /// it added, pruning qualifier folders it introduced once empty. A file
  /// without the generated marker was edited by hand or written by another
  /// tool — it is left alone and reported as skipped.
  RemoveResult remove() {
    final restored = <String>[];
    final deleted = <String>[];
    final skipped = <String>[];

    bool owned(File file) =>
        file.readAsStringSync().contains(generatedNoticeMarker);

    void restore(String qualifier, String stockContent) {
      final file = fs.file(
        fs.path.join(_resDir, qualifier, 'launch_background.xml'),
      );
      if (!file.existsSync()) return;
      if (!owned(file)) {
        // Already stock (e.g. remove ran twice) is fine — only flag files
        // with genuinely foreign contents.
        if (file.readAsStringSync() != stockContent) {
          skipped.add(file.path);
        }
        return;
      }
      file.writeAsStringSync(stockContent);
      restored.add(file.path);
    }

    void delete(String qualifier, String fileName) {
      final file = fs.file(fs.path.join(_resDir, qualifier, fileName));
      if (!file.existsSync()) return;
      if (!owned(file)) {
        skipped.add(file.path);
        return;
      }
      file.deleteSync();
      deleted.add(file.path);
      final dir = fs.directory(fs.path.join(_resDir, qualifier));
      if (_introducedQualifiers.contains(qualifier) && dir.listSync().isEmpty) {
        dir.deleteSync();
      }
    }

    restore('drawable', stockAndroidLaunchBackground);
    restore('drawable-v21', stockAndroidLaunchBackgroundV21);
    delete('drawable', 'splash_icon_blank.xml');
    delete('drawable-night', 'launch_background.xml');
    delete('drawable-night-v21', 'launch_background.xml');
    delete('values-v31', 'styles.xml');
    delete('values-night-v31', 'styles.xml');

    return (restored: restored, deleted: deleted, skipped: skipped);
  }

  /// Qualifier folders absent from the stock template, so safe to prune
  /// when `remove` empties them.
  static const _introducedQualifiers = {
    'drawable-night',
    'drawable-night-v21',
    'values-v31',
    'values-night-v31',
  };

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
