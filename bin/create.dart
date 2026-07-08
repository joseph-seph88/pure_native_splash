import 'dart:io';

import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:pure_native_splash/src/android_writer.dart';
import 'package:pure_native_splash/src/config.dart';
import 'package:pure_native_splash/src/ios_writer.dart';

void main() {
  const fs = LocalFileSystem();
  final projectRoot = Directory.current.path;
  final androidWriter = AndroidSplashWriter(fs, projectRoot);
  final iosWriter = IosSplashWriter(fs, projectRoot);

  final hasAndroid = androidWriter.hasAndroidPlatform;
  final hasIos = iosWriter.hasIosPlatform;

  if (!hasAndroid && !hasIos) {
    stderr.writeln(
      'pure_native_splash: no android/ or ios/ directory found under '
      '$projectRoot.\n'
      'Run this from the root of a Flutter project that has at least one '
      'platform added (e.g. flutter create --platforms=android,ios .).',
    );
    exitCode = 1;
    return;
  }

  final PureNativeSplashConfig config;
  try {
    config = PureNativeSplashConfig.readFromProject(fs, projectRoot);
  } on FormatException catch (e) {
    // Use toString(), not e.message: for YAML syntax errors (YamlException
    // is a FormatException) toString() includes the line/column/caret
    // pointer that .message alone discards.
    stderr.writeln('pure_native_splash: $e');
    exitCode = 1;
    return;
  }

  final written = <String>[
    if (hasAndroid) ...androidWriter.write(config),
    if (hasIos) ...iosWriter.write(config),
  ];

  stdout.writeln('pure_native_splash: wrote ${written.length} files:');
  for (final path in written) {
    stdout.writeln('  - ${p.relative(path, from: projectRoot)}');
  }

  if (!hasAndroid) {
    stdout.writeln(
      '\npure_native_splash: no android/ directory found — skipped Android '
      'files.',
    );
  }
  if (!hasIos) {
    stdout.writeln(
      '\npure_native_splash: no ios/ directory found — skipped iOS files.',
    );
  }
  if (hasAndroid) {
    stdout.writeln(
      '\nIf any of these Android resource folders (drawable-night, '
      'drawable-night-v21, values-v31, values-night-v31) were just created '
      "for the first time, run `flutter clean` once before your next "
      "build — Gradle's incremental build can miss brand-new resource "
      'qualifiers otherwise.',
    );
  }
}
