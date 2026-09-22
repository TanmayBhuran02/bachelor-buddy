import 'package:flutter_test/flutter_test.dart';
import 'package:bachelor_buddy/core/money.dart';

void main() {
  group('Money Utility', () {
    test('formats paise correctly with Indian numbering', () {
      expect(Money.format(10000), '₹100.00');
      expect(Money.format(125050), '₹1,250.50');
      expect(Money.format(10000000), '₹1,00,000.00');
      expect(Money.format(10000000, showDecimal: false), '₹1,00,000');
    });

    test('parses rupee string to paise integer accurately', () {
      expect(Money.parse('100'), 10000);
      expect(Money.parse('₹1,250.50'), 125050);
      expect(Money.parse('25.75'), 2575);
      expect(Money.parse(''), 0);
    });

    test('extracts amounts from free text patterns', () {
      expect(Money.extractFromText('Bought chai for ₹20'), 2000);
      expect(Money.extractFromText('DMart groceries Rs. 450'), 45000);
      expect(Money.extractFromText('Dinner 150 rs'), 15000);
      expect(Money.extractFromText('No price mentioned'), isNull);
    });
  });
}
