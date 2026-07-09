final _hexColorPattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

/// Normalizes to uppercase `#RRGGBB`/`#AARRGGBB`, throwing a user-facing
/// [FormatException] for anything else.
String normalizeHexColor(String input, {required String fieldName}) {
  final trimmed = input.trim();
  final match = _hexColorPattern.firstMatch(trimmed);
  if (match == null) {
    throw FormatException(
      'Invalid $fieldName: "$input". Expected a hex color like "#FFFFFF" '
      'or "#FF112233" (with alpha).',
    );
  }
  return '#${match.group(1)!.toUpperCase()}';
}

/// 0-1 sRGB components as 3-decimal strings — the format Xcode's colorset
/// `Contents.json` uses. [hex] must already be normalized by
/// [normalizeHexColor]; this does not re-validate it.
({String red, String green, String blue, String alpha}) hexToSrgbComponents(
  String hex,
) {
  final digits = hex.startsWith('#') ? hex.substring(1) : hex;
  final String aa, rr, gg, bb;
  if (digits.length == 8) {
    aa = digits.substring(0, 2);
    rr = digits.substring(2, 4);
    gg = digits.substring(4, 6);
    bb = digits.substring(6, 8);
  } else {
    aa = 'FF';
    rr = digits.substring(0, 2);
    gg = digits.substring(2, 4);
    bb = digits.substring(4, 6);
  }
  String component(String twoHexDigits) =>
      (int.parse(twoHexDigits, radix: 16) / 255).toStringAsFixed(3);
  return (
    red: component(rr),
    green: component(gg),
    blue: component(bb),
    alpha: component(aa),
  );
}
