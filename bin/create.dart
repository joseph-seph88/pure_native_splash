import 'dart:io';

import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:pure_native_splash/src/android_writer.dart';
import 'package:pure_native_splash/src/config.dart';

void main() {
  const fs = LocalFileSystem();
  final projectRoot = Directory.current.path;
  final writer = AndroidSplashWriter(fs, projectRoot);

  if (!writer.hasAndroidPlatform) {
    stderr.writeln(
      'pure_native_splash: no android/ directory found under $projectRoot.\n'
      'Run this from the root of a Flutter project that has the Android '
      'platform added (flutter create --platforms=android .).',
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

  final written = writer.write(config);
  stdout.writeln('pure_native_splash: wrote ${written.length} files:');
  for (final path in written) {
    stdout.writeln('  - ${p.relative(path, from: projectRoot)}');
  }
  stdout.writeln(
    '\nIf any of these resource folders (values-v31, values-night-v31) were '
    'just created for the first time, run `flutter clean` once before your '
    "next build — Gradle's incremental build can miss brand-new values-* "
    'qualifiers otherwise.',
  );
}
