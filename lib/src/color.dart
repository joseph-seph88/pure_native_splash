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
