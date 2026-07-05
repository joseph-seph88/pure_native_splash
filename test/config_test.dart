import 'package:file/memory.dart';
import 'package:pure_native_splash/src/config.dart';
import 'package:test/test.dart';

void main() {
  group('PureNativeSplashConfig.parse', () {
    test('parses color and defaults color_dark to color', () {
      final config = PureNativeSplashConfig.parse('''
name: some_app

pure_native_splash:
  color: "#FFFFFF"
''');
      expect(config.color, '#FFFFFF');
      expect(config.colorDark, '#FFFFFF');
    });

    test('parses distinct color_dark when provided', () {
      final config = PureNativeSplashConfig.parse('''
name: some_app

pure_native_splash:
  color: "#FFFFFF"
  color_dark: "#000000"
''');
      expect(config.color, '#FFFFFF');
      expect(config.colorDark, '#000000');
    });

    test('throws when pure_native_splash section is missing', () {
      expect(
        () => PureNativeSplashConfig.parse('name: some_app\n'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('pure_native_splash:'),
          ),
        ),
      );
    });

    test('throws when color is missing', () {
      expect(
        () => PureNativeSplashConfig.parse('''
name: some_app

pure_native_splash:
  color_dark: "#000000"
'''),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('pure_native_splash.color'),
          ),
        ),
      );
    });

    test('throws on invalid color format', () {
      expect(
        () => PureNativeSplashConfig.parse('''
pure_native_splash:
  color: "blue"
'''),
        throwsFormatException,
      );
    });
  });

  group('PureNativeSplashConfig.readFromProject', () {
    test('reads pubspec.yaml from the given filesystem and root', () {
      final fs = MemoryFileSystem();
      fs.directory('/app').createSync();
      fs.file('/app/pubspec.yaml').writeAsStringSync('''
name: some_app

pure_native_splash:
  color: "#123456"
''');

      final config = PureNativeSplashConfig.readFromProject(fs, '/app');
      expect(config.color, '#123456');
      expect(config.colorDark, '#123456');
    });

    test('throws a clear error when pubspec.yaml does not exist', () {
      final fs = MemoryFileSystem();
      fs.directory('/app').createSync();

      expect(
        () => PureNativeSplashConfig.readFromProject(fs, '/app'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('No pubspec.yaml found'),
          ),
        ),
      );
    });
  });
}
