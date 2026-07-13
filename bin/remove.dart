import 'dart:io';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:pure_native_splash/src/android_writer.dart';
import 'package:pure_native_splash/src/cli_banner.dart';
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
      'Run this from the root of a Flutter project.',
    );
    exitCode = 1;
    return;
  }

  if (hasAndroid) printStep('Restoring Android splash resources');
  final androidResult = hasAndroid ? androidWriter.remove() : null;
  if (hasIos) printStep('Restoring iOS splash resources');
  final iosResult = hasIos ? iosWriter.remove() : null;

  final results = [
    if (androidResult != null) androidResult,
    if (iosResult != null) iosResult,
  ];
  final restored = [for (final r in results) ...r.restored];
  final deleted = [for (final r in results) ...r.deleted];
  final skipped = [for (final r in results) ...r.skipped];

  void printSection(String label, List<String> paths) {
    if (paths.isEmpty) return;
    stdout.writeln('$label:');
    for (final path in paths) {
      stdout.writeln('  - ${p.relative(path, from: projectRoot)}');
    }
  }

  printSuccess(
    'Restored ${restored.length} files, deleted ${deleted.length} files',
  );
  printSection('Restored', restored);
  printSection('Deleted', deleted);
  printSection(
    'Left alone (no pure_native_splash marker — edited by hand or written '
    'by another tool)',
    skipped,
  );

  if (restored.isEmpty && deleted.isEmpty && skipped.isEmpty) {
    stdout.writeln(
      'Nothing to remove — no files written by pure_native_splash found.',
    );
  }

  if (androidResult != null && androidResult.deleted.isNotEmpty) {
    stdout.writeln(
      '\nRun `flutter clean` once before your next build — Gradle\'s '
      'incremental build can miss deleted resource qualifiers otherwise.',
    );
  }
}
