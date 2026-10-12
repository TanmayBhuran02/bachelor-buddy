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
    'com.paytmmoney': 'Paytm Money',
    'com.paytm.business': 'Paytm',
    'money.super.payments': 'super.money',
    'money.super.app': 'super.money',
    'in.org.npci.upiapp': 'BHIM',
    'com.cred.club': 'CRED',
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
        lower.contains('refund') ||
        lower.contains('cashback') ||
        lower.contains('deposited')) {
      type = 'income';
    } else if (lower.contains('debited') ||
        lower.contains('debit') ||
        lower.contains('paid') ||
        lower.contains('sent') ||
        lower.contains('spent') ||
        lower.contains('payment') ||
        lower.contains('transferred') ||
        lower.contains('transfer') ||
        lower.contains('txn') ||
        lower.contains('transaction') ||
        lower.contains('success') ||
        lower.contains('successful')) {
      type = 'expense';
    } else {
      // If neither recognized transaction indicator is found, ignore
      return null;
    }

    // 2. Extract amount
    // Primary: ₹ / Rs / INR amounts
    Match? match = RegExp(
      r'(?:₹|rs\.?|inr\.?)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);

    // Secondary: keywords like "paid 150", "payment of 150", "sent 150", "amt: 150"
    match ??= RegExp(
      r'(?:paid|sent|payment(?:\s+of)?|transferred|amount(?:\s+of)?|amt\.?)\s+(?:(?:rs\.?|inr\.?|₹)\s*)?([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);

    // Tertiary: reverse "150 paid", "150 debited", "150 sent"
    match ??= RegExp(
      r'([\d,]+(?:\.\d{1,2})?)\s*(?:paid|debited|sent|spent|transferred|credited|received)',
      caseSensitive: false,
    ).firstMatch(text);

    if (match == null) return null;

    final amountStr = match.group(1)?.replaceAll(',', '');
    if (amountStr == null) return null;

    final amountDouble = double.tryParse(amountStr);
    if (amountDouble == null || amountDouble <= 0) return null;

    final amountPaise = (amountDouble * 100).round();

    // 3. Extract Merchant / Party Name
    String merchant = '';

    final partyPatterns = [
      // Pattern 1: paid [successfully] to X / payment [of Y] to X / sent [successfully] to X / received from X
      RegExp(
        r'(?:paid(?:\s+successfully)?\s+to|payment(?:\s+of\s+[^\s]+)?\s+to|sent(?:\s+successfully)?\s+to|transferred\s+to|received(?:\s+successfully)?\s+from)\s+([A-Za-z0-9\s\.\-_@&]+?)(?:\s*(?:[:;,\.\-]\s*|\s+(?:on|using|via|for|ref|upi|with|at|deposited|in\s+your|into|was|is|\.|$)))',
        caseSensitive: false,
      ),
      // Pattern 2: "to X" or "from X" (e.g. "Rs 200 to Ramesh Kumar via Paytm", "₹1 from Devendra ...")
      RegExp(
        r'(?:\bto\b|\bfrom\b)\s+([A-Za-z0-9\s\.\-_@&]+?)(?:\s*(?:[:;,\.\-]\s*|\s+(?:on|using|via|for|ref|upi|with|deposited|in\s+your|into|was|is|\.|$)))',
        caseSensitive: false,
      ),
      // Pattern 3: "at X" (e.g. "spent Rs 200 at Starbucks")
      RegExp(
        r'\bat\s+([A-Za-z0-9\s\.\-_@&]+?)(?:\s*(?:[:;,\.\-]\s*|\s+(?:on|using|via|for|ref|upi|\.|$)))',
        caseSensitive: false,
      ),
      // Pattern 4: "Paid to X:" or "Payment to X:"
      RegExp(
        r'(?:paid|payment|sent|transfer(?:red)?)\s+to\s+([A-Za-z0-9\s\.\-_@&]+?)(?:\s*[:,\-]|\s+for|\s+of)',
        caseSensitive: false,
      ),
    ];

    for (final reg in partyPatterns) {
      final m = reg.firstMatch(text);
      if (m != null) {
        var candidate = m.group(1)?.trim() ?? '';
        candidate = candidate.replaceAll(RegExp(r'^[\s\-:]+|[\s\-:]+$'), '').trim();
        final lowerCand = candidate.toLowerCase();
        if (candidate.isNotEmpty &&
            !lowerCand.startsWith('your') &&
            !lowerCand.startsWith('a/c') &&
            !lowerCand.startsWith('account') &&
            !lowerCand.startsWith('vpa') &&
            !lowerCand.startsWith('bank') &&
            !lowerCand.startsWith('rs') &&
            !lowerCand.startsWith('inr') &&
            !lowerCand.startsWith('₹')) {
          merchant = candidate;
          break;
        }
      }
    }

    if (merchant.length > 40) {
      merchant = merchant.substring(0, 40).trim();
    }

    if (merchant.isEmpty) {
      merchant = type == 'expense' ? 'UPI Payment' : 'UPI Received';
    }

    String appSource = _knownPackages[packageName] ?? '';
    if (appSource.isEmpty) {
      if (packageName.toLowerCase().contains('paytm')) {
        appSource = 'Paytm';
      } else if (packageName.toLowerCase().contains('super')) {
        appSource = 'super.money';
      } else {
        appSource = 'Bank/UPI';
      }
    }

    return ParsedTransaction(
      amountPaise: amountPaise,
      type: type,
      merchantOrParty: merchant,
      rawText: text,
      appSource: appSource,
    );
  }
}
