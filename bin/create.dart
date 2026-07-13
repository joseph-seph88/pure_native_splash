import 'dart:io';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:pure_native_splash/src/android_writer.dart';
import 'package:pure_native_splash/src/cli_banner.dart';
import 'package:pure_native_splash/src/config.dart';
import 'package:pure_native_splash/src/ios_writer.dart';

Future<void> main() async {
  printBanner('PURE NATIVE SPLASH (v${await resolvePackageVersion()})');

  const fs = LocalFileSystem();
  final projectRoot = Directory.current.path;
  final androidWriter = AndroidSplashWriter(fs, projectRoot);
  final iosWriter = IosSplashWriter(fs, projectRoot);

  final hasAndroid = androidWriter.hasAndroidPlatform;
  final hasIos = iosWriter.hasIosPlatform;

  if (!hasAndroid && !hasIos) {
    stderr.writeln(
      'No android/ or ios/ directory found under $projectRoot.\n'
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
    stderr.writeln(e);
    exitCode = 1;
    return;
  }

  final newQualifiers =
      hasAndroid ? androidWriter.missingIntroducedQualifiers : <String>[];

  final written = <String>[];
  if (hasAndroid) {
    printStep('Writing Android splash resources');
    written.addAll(androidWriter.write(config));
  }
  if (hasIos) {
    printStep('Writing iOS splash resources');
    written.addAll(iosWriter.write(config));
  }

  printSuccess('Successfully generated native splash (${written.length} '
      'files)');
  for (final path in written) {
    stdout.writeln('  - ${p.relative(path, from: projectRoot)}');
  }

  if (!hasAndroid) {
    stdout.writeln('\nNo android/ directory found — skipped Android files.');
  }
  if (!hasIos) {
    stdout.writeln('\nNo ios/ directory found — skipped iOS files.');
  }
  if (newQualifiers.isNotEmpty) {
    stdout.writeln(
      '\nNew Android resource folders were created '
      '(${newQualifiers.join(', ')}). Run `flutter clean` once before '
      "your next build — Gradle's incremental build can miss brand-new "
      'resource qualifiers otherwise.',
    );
  }
}
