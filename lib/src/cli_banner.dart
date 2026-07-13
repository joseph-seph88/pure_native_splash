import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:yaml/yaml.dart';

/// Reads `version:` out of this package's own pubspec.yaml — not the
/// consuming project's — so the CLI banner always matches whatever is
/// published, with nothing to keep in sync by hand.
///
/// Resolved via the running program's package_config.json (`packages:
/// [{name, rootUri}, ...]`), which maps the `pure_native_splash` package
/// name to its on-disk root regardless of whether it was resolved from
/// pub.dev, a path dependency, or a git dependency.
Future<String> resolvePackageVersion() async {
  final packageConfigUri = await Isolate.packageConfig;
  if (packageConfigUri == null) return 'unknown';

  final packageConfigFile = File.fromUri(packageConfigUri);
  if (!packageConfigFile.existsSync()) return 'unknown';

  final config = jsonDecode(await packageConfigFile.readAsString())
      as Map<String, Object?>;
  final packages = config['packages'] as List<Object?>? ?? const [];

  for (final entry in packages) {
    final package = entry as Map<String, Object?>;
    if (package['name'] != 'pure_native_splash') continue;

    final rootUri = package['rootUri'] as String;
    final pubspecFile = File.fromUri(
      packageConfigFile.uri.resolve(rootUri).resolve('pubspec.yaml'),
    );
    if (!pubspecFile.existsSync()) return 'unknown';

    final doc = loadYaml(await pubspecFile.readAsString());
    final version = doc is Map ? doc['version'] : null;
    return version is String ? version : 'unknown';
  }

  return 'unknown';
}

const _titleIndent = '   ';

void printBanner(String title) {
  final line = '═' * (title.length + _titleIndent.length * 2);
  stdout
    ..writeln(line)
    ..writeln('$_titleIndent$title')
    ..writeln(line)
    ..writeln();
}

void printStep(String message) => stdout.writeln('• $message');

void printSuccess(String message) => stdout.writeln('\n✓ $message');
