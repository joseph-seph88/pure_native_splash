import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'color.dart';

/// The resolved `pure_native_splash:` configuration read from a consuming
/// app's `pubspec.yaml`.
class PureNativeSplashConfig {
  const PureNativeSplashConfig({required this.color, required this.colorDark});

  /// Light-mode splash background color, normalized to `#RRGGBB`/`#AARRGGBB`.
  final String color;

  /// Dark-mode splash background color. Equal to [color] if not specified.
  final String colorDark;

  /// Parses the `pure_native_splash:` section out of raw `pubspec.yaml`
  /// text. Throws a [FormatException] with a user-facing message if the
  /// section is missing or invalid.
  static PureNativeSplashConfig parse(String pubspecYamlContent) {
    final Object? doc = loadYaml(pubspecYamlContent);
    if (doc is! Map) {
      throw const FormatException('pubspec.yaml is empty or malformed.');
    }

    final Object? section = doc['pure_native_splash'];
    if (section is! Map) {
      throw const FormatException(
        'Missing `pure_native_splash:` section in pubspec.yaml. Add at '
        'least:\n\n'
        'pure_native_splash:\n'
        '  color: "#FFFFFF"\n',
      );
    }

    final Object? rawColor = section['color'];
    if (rawColor is! String) {
      throw const FormatException(
        'Missing required `pure_native_splash.color` in pubspec.yaml, e.g. '
        'color: "#FFFFFF".',
      );
    }
    final color = normalizeHexColor(
      rawColor,
      fieldName: 'pure_native_splash.color',
    );

    final Object? rawColorDark = section['color_dark'];
    final String colorDark;
    if (rawColorDark == null) {
      colorDark = color;
    } else if (rawColorDark is String) {
      colorDark = normalizeHexColor(
        rawColorDark,
        fieldName: 'pure_native_splash.color_dark',
      );
    } else {
      throw const FormatException(
        '`pure_native_splash.color_dark` must be a string, e.g. "#000000".',
      );
    }

    return PureNativeSplashConfig(color: color, colorDark: colorDark);
  }

  /// Reads and parses `pubspec.yaml` from [projectRoot] on [fs].
  static PureNativeSplashConfig readFromProject(
    FileSystem fs,
    String projectRoot,
  ) {
    final pubspecFile = fs.file(fs.path.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw FormatException('No pubspec.yaml found at ${pubspecFile.path}.');
    }
    return parse(pubspecFile.readAsStringSync());
  }
}
