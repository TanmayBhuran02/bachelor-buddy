/// Money utility for paise-based arithmetic.
/// All monetary values are stored as integer paise (1 ₹ = 100 paise).
/// Never use doubles for money calculations.
library;


class Money {
  /// Format paise as ₹ string with Indian numbering (e.g., ₹1,25,000.50)
  static String format(int paise, {bool showDecimal = true}) {
    final rupees = paise / 100;
    if (showDecimal) {
      // Indian numbering format
      return '₹${_formatIndian(rupees)}';
    } else {
      return '₹${_formatIndian(rupees.truncateToDouble(), decimals: 0)}';
    }
  }

  /// Format without the ₹ symbol
  static String formatRaw(int paise, {bool showDecimal = true}) {
    final rupees = paise / 100;
    if (showDecimal) {
      return _formatIndian(rupees);
    } else {
      return _formatIndian(rupees.truncateToDouble(), decimals: 0);
    }
  }

  /// Parse a string like "₹1,250.50" or "1250.50" or "1250" to paise
  static int parse(String input) {
    // Remove ₹ symbol, commas, and whitespace
    final cleaned = input
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    if (cleaned.isEmpty) return 0;

    final value = double.tryParse(cleaned);
    if (value == null) return 0;

    return (value * 100).round();
  }

  /// Convert rupees (double) to paise. Use sparingly.
  static int rupeesToPaise(double rupees) => (rupees * 100).round();

  /// Convert paise to rupees as double. Use only for display.
  static double paiseToRupees(int paise) => paise / 100;

  /// Extract amount in paise from text using regex patterns like "₹299", "300 rs", "rs.500"
  static int? extractFromText(String text) {
    // Patterns: ₹299, ₹ 299, 299₹, Rs.299, Rs 299, 299 rs, 299rs
    final patterns = [
      RegExp(r'₹\s*(\d+(?:[.,]\d+)?)', caseSensitive: false),
      RegExp(r'rs\.?\s*(\d+(?:[.,]\d+)?)', caseSensitive: false),
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:₹|rs\.?|rupees?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final numStr = match.group(1)?.replaceAll(',', '');
        if (numStr != null) {
          final value = double.tryParse(numStr);
          if (value != null) {
            return (value * 100).round();
          }
        }
      }
    }
    return null;
  }

  /// Indian numbering format: 1,00,000.00
  static String _formatIndian(double value, {int decimals = 2}) {
    final isNegative = value < 0;
    final absValue = value.abs();

    String intPart = absValue.truncate().toString();
    final decPart = decimals > 0
        ? '.${(absValue % 1).toStringAsFixed(decimals).substring(2)}'
        : '';

    // Apply Indian grouping: last 3 digits, then groups of 2
    if (intPart.length > 3) {
      final last3 = intPart.substring(intPart.length - 3);
      String rest = intPart.substring(0, intPart.length - 3);
      final buffer = StringBuffer();
      while (rest.length > 2) {
        buffer.write('${rest.substring(0, rest.length - 2)},');
        rest = rest.substring(rest.length - 2);
      }
      buffer.write(rest);
      intPart = '${buffer.toString()},$last3';
    }

    return '${isNegative ? '-' : ''}$intPart$decPart';
  }
}
