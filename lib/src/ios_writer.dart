import 'dart:convert';
import 'package:file/file.dart';
import 'color.dart';
import 'config.dart';
import 'generated_notice.dart';
import 'remove_result.dart';
import 'stock_templates.dart';

/// Writes the iOS resources this package owns: a `LaunchScreen.storyboard`
/// (Flutter's stock template with the background color swapped for an
/// asset-catalog named color) and the `LaunchBackground.colorset` defining
/// that color's light/dark variants.
///
/// Unlike the stock template, the storyboard has no `LaunchImage` image
/// view — tools like flutter_native_splash fill that imageset with a logo,
/// and keeping the view would resurface it on top of this package's color.
///
/// `project.pbxproj` and `Info.plist` are deliberately never opened — same
/// ownership philosophy as [AndroidSplashWriter]. Assumes the stock
/// `flutter create` `ios/Runner/...` layout.
class IosSplashWriter {
  IosSplashWriter(this.fs, this.projectRoot);

  final FileSystem fs;
  final String projectRoot;

  String get _iosDir => fs.path.join(projectRoot, 'ios');

  String get _runnerDir => fs.path.join(_iosDir, 'Runner');

  bool get hasIosPlatform => fs.directory(_iosDir).existsSync();

  /// Always overwrites prior contents; returns the paths written.
  List<String> write(PureNativeSplashConfig config) {
    return <String>[
      _writeLaunchScreenStoryboard(),
      _writeLaunchBackgroundColorset(config),
    ];
  }

  /// Restores the stock storyboard and deletes the colorset, mirroring
  /// [AndroidSplashWriter.remove]: files without this package's marker
  /// (the XML banner, or `info.author` for the colorset) are left alone
  /// and reported as skipped.
  RemoveResult remove() {
    final restored = <String>[];
    final deleted = <String>[];
    final skipped = <String>[];

    final storyboard = fs.file(
      fs.path.join(_runnerDir, 'Base.lproj', 'LaunchScreen.storyboard'),
    );
    if (storyboard.existsSync()) {
      final content = storyboard.readAsStringSync();
      if (content.contains(generatedNoticeMarker)) {
        storyboard.writeAsStringSync(stockLaunchScreenStoryboard);
        restored.add(storyboard.path);
      } else if (content != stockLaunchScreenStoryboard) {
        // Already stock (e.g. remove ran twice) is fine — only flag files
        // with genuinely foreign contents.
        skipped.add(storyboard.path);
      }
    }

    final contentsJson = fs.file(
      fs.path.join(
        _runnerDir,
        'Assets.xcassets',
        'LaunchBackground.colorset',
        'Contents.json',
      ),
    );
    if (contentsJson.existsSync()) {
      if (_ownsColorset(contentsJson)) {
        contentsJson.deleteSync();
        deleted.add(contentsJson.path);
        final dir = contentsJson.parent;
        if (dir.listSync().isEmpty) {
          dir.deleteSync();
        }
      } else {
        skipped.add(contentsJson.path);
      }
    }

    return (restored: restored, deleted: deleted, skipped: skipped);
  }

  /// Parsed rather than substring-matched so reformatting (Xcode, JSON
  /// formatters) doesn't disguise our own colorset as foreign.
  static bool _ownsColorset(File file) {
    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException {
      return false;
    }
    if (decoded is! Map) return false;
    final info = decoded['info'];
    return info is Map && info['author'] == 'pure_native_splash';
  }

  String _writeLaunchScreenStoryboard() {
    final file = fs.file(
      fs.path.join(_runnerDir, 'Base.lproj', 'LaunchScreen.storyboard'),
    );
    file.createSync(recursive: true);
    file.writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="12121" systemVersion="16G29" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    $generatedNoticeXmlComment
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12089"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <layoutGuides>
                        <viewControllerLayoutGuide type="top" id="Ydg-fD-yQy"/>
                        <viewControllerLayoutGuide type="bottom" id="xbc-2k-c8Z"/>
                    </layoutGuides>
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" name="LaunchBackground"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
</document>
''');
    return file.path;
  }

  String _writeLaunchBackgroundColorset(PureNativeSplashConfig config) {
    final light = hexToSrgbComponents(config.color);
    final dark = hexToSrgbComponents(config.colorDark);

    Map<String, Object> colorEntry(
      ({String red, String green, String blue, String alpha}) c, {
      bool isDark = false,
    }) =>
        {
          'idiom': 'universal',
          if (isDark)
            'appearances': [
              {'appearance': 'luminosity', 'value': 'dark'},
            ],
          'color': {
            'color-space': 'srgb',
            'components': {
              'red': c.red,
              'green': c.green,
              'blue': c.blue,
              'alpha': c.alpha,
            },
          },
        };

    final json = <String, Object>{
      'colors': [colorEntry(light), colorEntry(dark, isDark: true)],
      'info': {'author': 'pure_native_splash', 'version': 1},
    };

    final file = fs.file(
      fs.path.join(
        _runnerDir,
        'Assets.xcassets',
        'LaunchBackground.colorset',
        'Contents.json',
      ),
    );
    file.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    return file.path;
  }
}
