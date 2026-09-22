/// Rule-based intent parser using keyword matching.
/// Detects expense-related intents from to-do titles.
library;

import 'package:bachelor_buddy/core/money.dart';
import 'action_intent.dart';

class LocalIntentParser implements IntentParser {
  // Category keyword mappings
  static const _categoryRules = <String, List<String>>{
    'Travel': [
      'ticket', 'bus', 'train', 'flight', 'cab', 'uber', 'ola', 'auto',
      'rickshaw', 'metro', 'taxi', 'travel', 'petrol', 'diesel', 'fuel',
    ],
    'Utilities': [
      'recharge', 'bill', 'electricity', 'wifi', 'internet', 'water bill',
      'gas bill', 'broadband', 'jio', 'airtel', 'vi',
    ],
    'Groceries': [
      'groceries', 'vegetables', 'veggies', 'milk', 'bread', 'eggs',
      'fruits', 'sabzi', 'kirana',
    ],
    'Rent': ['rent', 'house rent', 'room rent', 'pg rent'],
    'Food': [
      'food', 'lunch', 'dinner', 'breakfast', 'snack', 'chai', 'tea',
      'coffee', 'restaurant', 'zomato', 'swiggy', 'eat',
    ],
    'Health': [
      'medicine', 'doctor', 'hospital', 'medical', 'pharmacy', 'health',
      'gym', 'dentist',
    ],
    'Entertainment': [
      'movie', 'netflix', 'spotify', 'subscription', 'gaming', 'concert',
    ],
    'Shopping': [
      'amazon', 'flipkart', 'shopping', 'clothes', 'shoes',
    ],
    'Recharge/Bills': [
      'phone recharge', 'mobile recharge', 'dth', 'fastag',
    ],
  };

  @override
  Future<ActionIntent?> parse(String todoText) async {
    final lower = todoText.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // Try to match a category
    String? matchedCategory;
    for (final entry in _categoryRules.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          matchedCategory = entry.key;
          break;
        }
      }
      if (matchedCategory != null) break;
    }

    // No category match = no intent
    if (matchedCategory == null) return null;

    // Try to extract an amount
    final amountPaise = Money.extractFromText(todoText);

    return ActionIntent(
      type: 'create_expense',
      confidence: 0.8,
      payload: {
        'amountPaise': ?amountPaise,
        'categoryHint': matchedCategory,
        'note': todoText,
        'date': null, // use completion date
      },
    );
  }
}

/// Documented stub for future LLM-based intent parsing.
/// JSON contract the remote parser must return:
/// ```json
/// {
///   "type": "create_expense",
///   "confidence": 0.0-1.0,
///   "payload": {
///     "amountPaise": 0,
///     "categoryHint": "Travel",
///     "note": "",
///     "date": null
///   }
/// }
/// ```
/// Low-confidence or unknown types are never auto-executed;
/// they only ever produce a suggestion.
class RemoteIntentParser implements IntentParser {
  @override
  Future<ActionIntent?> parse(String todoText) async {
    // TODO: Implement LLM-based parsing via secure API.
    // API key should be stored in secure storage, never in source.
    // For now, fall back to null (no suggestion).
    return null;
  }
}
