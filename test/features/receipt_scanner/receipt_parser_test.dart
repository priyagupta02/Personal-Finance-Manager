import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/features/receipt_scanner/domain/receipt_parser.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';

void main() {
  const parser = ReceiptParser();

  test('parses a typical cafe receipt', () {
    const text = '''
Cafe Coffee Day
123 MG Road
Date: 14/06/2026
Cappuccino  180.00
Sandwich    220.00
Subtotal    400.00
Tax          20.00
Total       420.00
''';
    final r = parser.parse(text);

    expect(r.merchant, 'Cafe Coffee Day');
    expect(r.amount, 420.00); // total, not the 400 subtotal
    expect(r.date, DateTime(2026, 6, 14));
    expect(r.categorySuggestion, TransactionCategory.food);
  });

  test('handles thousands separators and ISO dates', () {
    const text = '''
SuperMart Grocery
2026-05-01
Total 1,250.50
''';
    final r = parser.parse(text);

    expect(r.amount, 1250.50);
    expect(r.date, DateTime(2026, 5, 1));
    expect(r.categorySuggestion, TransactionCategory.groceries);
  });

  test('falls back to the largest number when no total keyword', () {
    const text = 'Corner Store\n50\n300\n120';
    final r = parser.parse(text);
    expect(r.amount, 300);
  });

  test('empty text yields all-null fields', () {
    final r = parser.parse('');
    expect(r.amount, isNull);
    expect(r.date, isNull);
    expect(r.merchant, isNull);
    expect(r.categorySuggestion, isNull);
  });

  test('suggests transport from keywords', () {
    final r = parser.parse('Uber Trip\nFare 340.00\n12-06-2026');
    expect(r.categorySuggestion, TransactionCategory.transport);
    expect(r.date, DateTime(2026, 6, 12));
  });
}
