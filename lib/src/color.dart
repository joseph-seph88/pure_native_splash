final _hexColorPattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

/// Validates a hex color string and normalizes it to `#RRGGBB` or
/// `#AARRGGBB` with uppercase digits.
///
/// [fieldName] is used only to produce a clear error message, e.g.
/// `pure_native_splash.color`.
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

/// Converts an already-normalized `#RRGGBB`/`#AARRGGBB` hex color (as
/// returned by [normalizeHexColor]) into 0-1 sRGB float components
/// formatted as 3-decimal strings (e.g. `"1.000"`, `"0.200"`), matching the
/// format Xcode's asset-catalog `Contents.json` colorset entries use.
/// Alpha defaults to `"1.000"` when [hex] has no alpha channel (6 hex
/// digits). Does not itself validate [hex]'s format — callers must pass a
/// string already validated by [normalizeHexColor].
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
