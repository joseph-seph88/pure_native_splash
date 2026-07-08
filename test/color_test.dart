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

  group('hexToSrgbComponents', () {
    test('converts 6-digit hex to full-alpha components', () {
      final c = hexToSrgbComponents('#FFFFFF');
      expect(c.red, '1.000');
      expect(c.green, '1.000');
      expect(c.blue, '1.000');
      expect(c.alpha, '1.000');
    });

    test('defaults alpha to 1.000 when hex has no alpha channel', () {
      final c = hexToSrgbComponents('#3366FF');
      expect(c.alpha, '1.000');
    });

    test('converts a mid-range 6-digit hex to fractional components', () {
      final c = hexToSrgbComponents('#3366FF');
      expect(c.red, '0.200');
      expect(c.green, '0.400');
      expect(c.blue, '1.000');
    });

    test('converts 8-digit hex including a non-opaque alpha channel', () {
      final c = hexToSrgbComponents('#FF804020');
      expect(c.alpha, '1.000');
      expect(c.red, '0.502');
      expect(c.green, '0.251');
      expect(c.blue, '0.125');
    });
  });
}
