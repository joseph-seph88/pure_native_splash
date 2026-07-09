import 'package:file/file.dart';
import 'package:yaml/yaml.dart';
import 'color.dart';

/// The `pure_native_splash:` config from the consuming app's `pubspec.yaml`.
class PureNativeSplashConfig {
  const PureNativeSplashConfig({required this.color, required this.colorDark});

  /// Normalized to `#RRGGBB`/`#AARRGGBB`.
  final String color;

  /// Falls back to [color], or `#000000` when both were omitted.
  final String colorDark;

  /// Throws a user-facing [FormatException] if the section is missing or
  /// invalid.
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
    final String color;
    if (rawColor == null) {
      if (section.containsKey('color')) {
        throw const FormatException(
          '`pure_native_splash.color` has no value. If you wrote an '
          'unquoted hex color (e.g. `color: #FFFFFF`), YAML reads '
          'everything after `#` as a comment — quote it: '
          '`color: "#FFFFFF"`.',
        );
      }
      color = '#FFFFFF';
    } else if (rawColor is String) {
      color = normalizeHexColor(
        rawColor,
        fieldName: 'pure_native_splash.color',
      );
    } else {
      throw const FormatException(
        '`pure_native_splash.color` must be a string, e.g. "#FFFFFF".',
      );
    }

    final Object? rawColorDark = section['color_dark'];
    final String colorDark;
    if (rawColorDark == null) {
      if (section.containsKey('color_dark')) {
        throw const FormatException(
          '`pure_native_splash.color_dark` has no value. If you wrote an '
          'unquoted hex color (e.g. `color_dark: #000000`), YAML reads '
          'everything after `#` as a comment — quote it: '
          '`color_dark: "#000000"`.',
        );
      }
      // Mirror an explicit `color`; black only when nothing was configured.
      colorDark = rawColor == null ? '#000000' : color;
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
