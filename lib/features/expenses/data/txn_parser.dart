/// Transaction parser for Indian UPI and Banking notifications / SMS.
library;

class ParsedTransaction {
  final int amountPaise;
  final String type; // 'expense' | 'income'
  final String merchantOrParty;
  final String rawText;
  final String appSource;

  const ParsedTransaction({
    required this.amountPaise,
    required this.type,
    required this.merchantOrParty,
    required this.rawText,
    required this.appSource,
  });

  double get amountRupees => amountPaise / 100.0;
}

class TxnParser {
  static const Map<String, String> _knownPackages = {
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'com.phonepe.app': 'PhonePe',
    'net.one97.paytm': 'Paytm',
    'money.super.app': 'super.money',
    'com.whatsapp': 'WhatsApp Pay',
  };

  /// Parse incoming notification text
  static ParsedTransaction? parse({
    required String text,
    required String packageName,
  }) {
    if (text.trim().isEmpty) return null;

    final lower = text.toLowerCase();

    // 1. Detect type: debit (expense) or credit (income)
    String type = 'expense';
    if (lower.contains('credited') ||
        lower.contains('received') ||
        lower.contains('refunded') ||
        lower.contains('cashback')) {
      type = 'income';
    } else if (lower.contains('debited') ||
        lower.contains('paid') ||
        lower.contains('sent') ||
        lower.contains('spent') ||
        lower.contains('txn') ||
        lower.contains('transaction')) {
      type = 'expense';
    } else {
      // If neither keyword is found, not a recognized financial notification
      return null;
    }

    // 2. Extract amount
    // Matches patterns like: Rs. 500, Rs 500.50, INR 1,200.00, ₹450, 450.00 paid
    final amountReg = RegExp(
      r'(?:(?:rs|inr|₹)\.?\s*|paid\s+|sent\s+)([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = amountReg.firstMatch(text);
    if (match == null) return null;

    final amountStr = match.group(1)?.replaceAll(',', '');
    if (amountStr == null) return null;

    final amountDouble = double.tryParse(amountStr);
    if (amountDouble == null || amountDouble <= 0) return null;

    final amountPaise = (amountDouble * 100).round();

    // 3. Extract Merchant / Party Name
    String merchant = '';

    // Check patterns like: "paid to X", "sent to X", "from X", "at X", "transferred to X"
    final partyReg = RegExp(
      r'(?:paid\s+to|sent\s+to|transferred\s+to|received\s+from|from|at|to)\s+([A-Za-z0-9\s\.\-_@&]+?)(?:\s+(?:on|using|via|ref|upi|deposited|in\s+your|into|\.|$))',
      caseSensitive: false,
    );

    final partyMatch = partyReg.firstMatch(text);
    if (partyMatch != null) {
      merchant = partyMatch.group(1)?.trim() ?? '';
    }

    if (merchant.length > 40) {
      merchant = merchant.substring(0, 40).trim();
    }

    if (merchant.isEmpty) {
      merchant = type == 'expense' ? 'UPI Payment' : 'UPI Received';
    }

    final appSource = _knownPackages[packageName] ?? 'Bank/UPI';

    return ParsedTransaction(
      amountPaise: amountPaise,
      type: type,
      merchantOrParty: merchant,
      rawText: text,
      appSource: appSource,
    );
  }
}
