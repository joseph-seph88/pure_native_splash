import 'package:file/memory.dart';
import 'package:pure_native_splash/src/android_writer.dart';
import 'package:pure_native_splash/src/config.dart';
import 'package:pure_native_splash/src/stock_templates.dart';
import 'package:test/test.dart';

void main() {
  group('AndroidSplashWriter.hasAndroidPlatform', () {
    test('is false when android/ is missing', () {
      final fs = MemoryFileSystem();
      fs.directory('/app').createSync();
      expect(AndroidSplashWriter(fs, '/app').hasAndroidPlatform, isFalse);
    });

    test('is true when android/ exists', () {
      final fs = MemoryFileSystem();
      fs.directory('/app/android').createSync(recursive: true);
      expect(AndroidSplashWriter(fs, '/app').hasAndroidPlatform, isTrue);
    });
  });

  group('AndroidSplashWriter.write', () {
    late MemoryFileSystem fs;
    const projectRoot = '/app';
    const resDir = '/app/android/app/src/main/res';

    setUp(() {
      fs = MemoryFileSystem();
      fs.directory('$projectRoot/android').createSync(recursive: true);
    });

    test('writes exactly 7 files at the expected paths', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      final written = writer.write(
        const PureNativeSplashConfig(color: '#FFFFFF', colorDark: '#000000'),
      );

      expect(written, [
        '$resDir/drawable/splash_icon_blank.xml',
        '$resDir/drawable/launch_background.xml',
        '$resDir/drawable-v21/launch_background.xml',
        '$resDir/drawable-night/launch_background.xml',
        '$resDir/drawable-night-v21/launch_background.xml',
        '$resDir/values-v31/styles.xml',
        '$resDir/values-night-v31/styles.xml',
      ]);
      for (final path in written) {
        expect(fs.file(path).existsSync(), isTrue, reason: path);
      }
    });

    test('drawable is a transparent 1dp shape', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#FFFFFF', colorDark: '#000000'),
      );

      final content =
          fs.file('$resDir/drawable/splash_icon_blank.xml').readAsStringSync();
      expect(content, contains('android:color="#00000000"'));
      expect(content, contains('android:width="1dp"'));
      expect(content, contains('android:height="1dp"'));
    });

    test('drawable/launch_background.xml is a solid light-color shape', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#ABCDEF', colorDark: '#111111'),
      );

      final content =
          fs.file('$resDir/drawable/launch_background.xml').readAsStringSync();
      expect(content, contains('android:color="#ABCDEF"'));
      expect(content, isNot(contains('<size')));
    });

    test('drawable-v21/launch_background.xml is a solid light-color shape', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#ABCDEF', colorDark: '#111111'),
      );

      final content = fs
          .file('$resDir/drawable-v21/launch_background.xml')
          .readAsStringSync();
      expect(content, contains('android:color="#ABCDEF"'));
      expect(content, isNot(contains('<size')));
    });

    test('drawable-night/launch_background.xml is a solid dark-color shape',
        () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#ABCDEF', colorDark: '#111111'),
      );

      final content = fs
          .file('$resDir/drawable-night/launch_background.xml')
          .readAsStringSync();
      expect(content, contains('android:color="#111111"'));
      expect(content, isNot(contains('<size')));
    });

    test(
      'drawable-night-v21/launch_background.xml is a solid dark-color shape',
      () {
        final writer = AndroidSplashWriter(fs, projectRoot);
        writer.write(
          const PureNativeSplashConfig(
            color: '#ABCDEF',
            colorDark: '#111111',
          ),
        );

        final content = fs
            .file('$resDir/drawable-night-v21/launch_background.xml')
            .readAsStringSync();
        expect(content, contains('android:color="#111111"'));
        expect(content, isNot(contains('<size')));
      },
    );

    test('values-v31/styles.xml uses light color', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#ABCDEF', colorDark: '#111111'),
      );

      final content =
          fs.file('$resDir/values-v31/styles.xml').readAsStringSync();
      expect(
        content,
        contains('android:windowSplashScreenBackground">#ABCDEF<'),
      );
      expect(
        content,
        contains(
          'android:windowSplashScreenAnimatedIcon">@drawable/splash_icon_blank<',
        ),
      );
      expect(
        content,
        contains('android:windowSplashScreenIconBackgroundColor">#ABCDEF<'),
      );
      expect(
        content,
        contains('parent="@android:style/Theme.Light.NoTitleBar"'),
        reason:
            'must match the parent flutter create uses in values/styles.xml, '
            'not a .Fullscreen or dark variant',
      );
    });

    test('values-night-v31/styles.xml uses dark color', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#ABCDEF', colorDark: '#111111'),
      );

      final content =
          fs.file('$resDir/values-night-v31/styles.xml').readAsStringSync();
      expect(
        content,
        contains('android:windowSplashScreenBackground">#111111<'),
      );
      expect(
        content,
        contains('android:windowSplashScreenIconBackgroundColor">#111111<'),
      );
      expect(
        content,
        contains('parent="@android:style/Theme.Black.NoTitleBar"'),
        reason: 'must match the parent flutter create uses in '
            'values-night/styles.xml, not a .Fullscreen or light variant',
      );
    });

    test('re-running overwrites previous contents instead of appending', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(
        const PureNativeSplashConfig(color: '#111111', colorDark: '#222222'),
      );
      writer.write(
        const PureNativeSplashConfig(color: '#FFFFFF', colorDark: '#000000'),
      );

      final content =
          fs.file('$resDir/values-v31/styles.xml').readAsStringSync();
      expect(content, contains('#FFFFFF'));
      expect(content, isNot(contains('#111111')));
    });

    test('generated files carry a do-not-edit marker', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      final written = writer.write(
        const PureNativeSplashConfig(color: '#FFFFFF', colorDark: '#000000'),
      );

      for (final path in written) {
        expect(
          fs.file(path).readAsStringSync(),
          contains('GENERATED by pure_native_splash'),
        );
      }
    });
  });

  group('AndroidSplashWriter.remove', () {
    late MemoryFileSystem fs;
    const projectRoot = '/app';
    const resDir = '/app/android/app/src/main/res';
    const config = PureNativeSplashConfig(
      color: '#3366FF',
      colorDark: '#111111',
    );

    setUp(() {
      fs = MemoryFileSystem();
      fs.directory('$projectRoot/android').createSync(recursive: true);
    });

    test('after create, restores stock files and deletes generated ones', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(config);

      final result = writer.remove();

      expect(
        fs.file('$resDir/drawable/launch_background.xml').readAsStringSync(),
        stockAndroidLaunchBackground,
        reason: 'must be byte-identical to the flutter create template',
      );
      expect(
        fs
            .file('$resDir/drawable-v21/launch_background.xml')
            .readAsStringSync(),
        stockAndroidLaunchBackgroundV21,
        reason: 'must be byte-identical to the flutter create template',
      );

      expect(
        fs.file('$resDir/drawable/splash_icon_blank.xml').existsSync(),
        isFalse,
      );
      for (final dir in [
        'drawable-night',
        'drawable-night-v21',
        'values-v31',
        'values-night-v31',
      ]) {
        expect(
          fs.directory('$resDir/$dir').existsSync(),
          isFalse,
          reason: dir,
        );
      }
      expect(fs.directory('$resDir/drawable').existsSync(), isTrue);

      expect(result.restored, hasLength(2));
      expect(result.deleted, hasLength(5));
      expect(result.skipped, isEmpty);
    });

    test('leaves hand-written files alone and reports them as skipped', () {
      final custom = fs.file('$resDir/drawable/launch_background.xml');
      custom.createSync(recursive: true);
      custom.writeAsStringSync('<layer-list>custom</layer-list>');

      final result = AndroidSplashWriter(fs, projectRoot).remove();

      expect(custom.readAsStringSync(), contains('custom'));
      expect(result.skipped, [custom.path]);
      expect(result.restored, isEmpty);
      expect(result.deleted, isEmpty);
    });

    test('does not prune an introduced folder holding other files', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(config);
      final other = fs.file('$resDir/values-v31/other.xml');
      other.writeAsStringSync('<resources/>');

      writer.remove();

      expect(fs.file('$resDir/values-v31/styles.xml').existsSync(), isFalse);
      expect(other.existsSync(), isTrue);
    });

    test('is a no-op on a project where create never ran', () {
      final result = AndroidSplashWriter(fs, projectRoot).remove();

      expect(result.restored, isEmpty);
      expect(result.deleted, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('running twice reports nothing the second time', () {
      final writer = AndroidSplashWriter(fs, projectRoot);
      writer.write(config);
      writer.remove();

      final result = writer.remove();

      expect(result.restored, isEmpty);
      expect(result.deleted, isEmpty);
      expect(result.skipped, isEmpty);
    });
  });

  group('AndroidSplashWriter.missingIntroducedQualifiers', () {
    test(
        'lists all introduced qualifiers before the first write, and none '
        'after', () {
      final fs = MemoryFileSystem();
      fs.directory('/app/android').createSync(recursive: true);
      final writer = AndroidSplashWriter(fs, '/app');

      expect(writer.missingIntroducedQualifiers, [
        'drawable-night',
        'drawable-night-v21',
        'values-v31',
        'values-night-v31',
      ]);

      writer.write(
        const PureNativeSplashConfig(color: '#FFFFFF', colorDark: '#000000'),
      );

      expect(writer.missingIntroducedQualifiers, isEmpty);
    });
  });
}
