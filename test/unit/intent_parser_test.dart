import 'package:flutter_test/flutter_test.dart';
import 'package:bachelor_buddy/features/actions/local_intent_parser.dart';

void main() {
  group('LocalIntentParser', () {
    final parser = LocalIntentParser();

    test('detects grocery expense intent from task title', () async {
      final intent = await parser.parse('Buy vegetables and milk for ₹250');
      expect(intent, isNotNull);
      expect(intent!.type, 'create_expense');
      expect(intent.payload['amountPaise'], 25000);
      expect(intent.payload['categoryHint'], 'Groceries');
    });

    test('detects chai / food expense intent', () async {
      final intent = await parser.parse('Chai with colleagues 40 rs');
      expect(intent, isNotNull);
      expect(intent!.type, 'create_expense');
      expect(intent.payload['amountPaise'], 4000);
      expect(intent.payload['categoryHint'], 'Food');
    });

    test('returns null for tasks without financial keywords', () async {
      final intent = await parser.parse('Call mom this evening');
      expect(intent, isNull);
    });
  });
}
