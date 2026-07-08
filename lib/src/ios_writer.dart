import 'dart:convert';

import 'package:file/file.dart';

import 'color.dart';
import 'config.dart';
import 'generated_notice.dart';

/// Writes the fixed set of iOS resource files this package owns: a
/// `LaunchScreen.storyboard` regenerated from Flutter's stock template with
/// its background color swapped for a reference to an asset-catalog named
/// color, and the `LaunchBackground.colorset/Contents.json` that defines
/// that color's light and dark variants.
///
/// This package deliberately never opens `project.pbxproj` or `Info.plist`
/// — only the storyboard and the new colorset are fully owned/regenerated,
/// same ownership philosophy as [AndroidSplashWriter]. Assumes the stock
/// `flutter create` `ios/Runner/...` layout.
class IosSplashWriter {
  IosSplashWriter(this.fs, this.projectRoot);

  final FileSystem fs;
  final String projectRoot;

  String get _iosDir => fs.path.join(projectRoot, 'ios');

  String get _runnerDir => fs.path.join(_iosDir, 'Runner');

  /// Whether this looks like a Flutter project with the iOS platform added
  /// (i.e. has an `ios/` folder to write into).
  bool get hasIosPlatform => fs.directory(_iosDir).existsSync();

  /// Writes both files for [config], always overwriting prior contents.
  /// Returns the absolute paths written, in a fixed order.
  List<String> write(PureNativeSplashConfig config) {
    return <String>[
      _writeLaunchScreenStoryboard(),
      _writeLaunchBackgroundColorset(config),
    ];
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
                        <subviews>
                            <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
                            </imageView>
                        </subviews>
                        <color key="backgroundColor" name="LaunchBackground"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4X2-HB-R7a"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="168" height="185"/>
    </resources>
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
    }) => {
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
