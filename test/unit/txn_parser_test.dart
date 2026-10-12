import 'package:flutter_test/flutter_test.dart';
import 'package:bachelor_buddy/features/expenses/data/txn_parser.dart';

void main() {
  group('TxnParser', () {
    test('parses Google Pay debit notification', () {
      const text = 'Paid ₹450 to Swiggy on Google Pay';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'com.google.android.apps.nbu.paisa.user',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 45000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Swiggy');
      expect(txn.appSource, 'Google Pay');
    });

    test('parses PhonePe debit notification', () {
      const text = 'Rs. 1,250.00 debited from A/C XX1234 sent to Tanmay via UPI';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'com.phonepe.app',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 125000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Tanmay');
      expect(txn.appSource, 'PhonePe');
    });

    test('parses super.money UPI notification with official package money.super.payments', () {
      const text = '₹200.00 paid to Starbucks using super.money';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'money.super.payments',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 20000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Starbucks');
      expect(txn.appSource, 'super.money');
    });

    test('parses super.money UPI notification with legacy package money.super.app', () {
      const text = 'Payment of ₹85 to Chai Sutta Bar was successful';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'money.super.app',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 8500);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Chai Sutta Bar');
      expect(txn.appSource, 'super.money');
    });

    test('parses Paytm paid successfully notification', () {
      const text = 'Rs 150 paid successfully to Ramesh Kumar. Ref: 1234567890';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'net.one97.paytm',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 15000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Ramesh Kumar');
      expect(txn.appSource, 'Paytm');
    });

    test('parses Paytm payment of X to Y was successful', () {
      const text = 'Payment of ₹250 to Chai Point was successful';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'net.one97.paytm',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 25000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Chai Point');
      expect(txn.appSource, 'Paytm');
    });

    test('parses Paytm transferred notification', () {
      const text = 'Transferred ₹1,200 to Sharma Mess via Paytm UPI';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'net.one97.paytm',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 120000);
      expect(txn.type, 'expense');
      expect(txn.merchantOrParty, 'Sharma Mess');
      expect(txn.appSource, 'Paytm');
    });

    test('parses Credit / Income notification', () {
      const text = 'A/C 1234 credited by Rs. 5000.00 on 10-Oct-26';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'net.one97.paytm',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 500000);
      expect(txn.type, 'income');
      expect(txn.appSource, 'Paytm');
    });

    test('parses Paytm received from person notification', () {
      const text =
          'Received ₹1 from Mr Devendra Madhukar Dhande1 Deposited in your Bank Of Maharashtra - 4271 on 11 October at 2:41 AM';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'net.one97.paytm',
      );

      expect(txn, isNotNull);
      expect(txn!.amountPaise, 100);
      expect(txn.type, 'income');
      expect(txn.merchantOrParty, 'Mr Devendra Madhukar Dhande1');
      expect(txn.appSource, 'Paytm');
    });

    test('ignores non-transaction notification', () {
      const text = 'Check out exciting deals on electronics today!';
      final txn = TxnParser.parse(
        text: text,
        packageName: 'com.phonepe.app',
      );

      expect(txn, isNull);
    });
  });
}
