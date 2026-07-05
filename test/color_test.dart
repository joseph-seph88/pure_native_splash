import 'package:pure_native_splash/src/color.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeHexColor', () {
    test('accepts and uppercases 6-digit hex', () {
      expect(normalizeHexColor('#ffffff', fieldName: 'color'), '#FFFFFF');
    });

    test('accepts 8-digit hex with alpha', () {
      expect(normalizeHexColor('#ff112233', fieldName: 'color'), '#FF112233');
    });

    test('trims surrounding whitespace', () {
      expect(normalizeHexColor('  #000000  ', fieldName: 'color'), '#000000');
    });

    test('rejects missing #', () {
      expect(
        () => normalizeHexColor('FFFFFF', fieldName: 'color'),
        throwsFormatException,
      );
    });

    test('rejects wrong digit count', () {
      expect(
        () => normalizeHexColor('#FFF', fieldName: 'color'),
        throwsFormatException,
      );
    });

    test('rejects non-hex characters', () {
      expect(
        () => normalizeHexColor('#GGGGGG', fieldName: 'color'),
        throwsFormatException,
      );
    });

    test('error message includes the field name', () {
      expect(
        () => normalizeHexColor('nope', fieldName: 'pure_native_splash.color'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('pure_native_splash.color'),
          ),
        ),
      );
    });
  });
}
