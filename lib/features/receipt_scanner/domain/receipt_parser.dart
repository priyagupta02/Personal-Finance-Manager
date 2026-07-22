import '../../transactions/domain/entities/transaction_enums.dart';
import 'entities/scanned_receipt.dart';

/// Extracts structured fields from raw OCR text. Pure and dependency-free so it
/// can be unit-tested without a camera or the ML Kit plugin.
class ReceiptParser {
  const ReceiptParser();

  ScannedReceipt parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return ScannedReceipt(
      amount: _amount(lines),
      date: _date(rawText),
      merchant: _merchant(lines),
      categorySuggestion: _category(rawText.toLowerCase()),
      rawText: rawText,
    );
  }

  /// First line that looks like a name (has letters) — usually the store name.
  String? _merchant(List<String> lines) {
    for (final line in lines) {
      if (RegExp(r'[A-Za-z]{2,}').hasMatch(line) &&
          !RegExp(r'total|receipt|invoice|tax', caseSensitive: false)
              .hasMatch(line)) {
        return line;
      }
    }
    return lines.isNotEmpty ? lines.first : null;
  }

  /// Prefers a number on a "total" line; falls back to the largest number seen.
  double? _amount(List<String> lines) {
    double? fromKeyword;
    for (final line in lines) {
      final lower = line.toLowerCase();
      final isTotal = (lower.contains('total') && !lower.contains('subtotal')) ||
          lower.contains('amount') ||
          lower.contains('balance') ||
          lower.contains('due');
      if (isTotal) {
        final nums = _numbers(line);
        if (nums.isNotEmpty) {
          final max = nums.reduce((a, b) => a > b ? a : b);
          fromKeyword =
              fromKeyword == null || max > fromKeyword ? max : fromKeyword;
        }
      }
    }
    if (fromKeyword != null) return fromKeyword;

    final all = lines.expand(_numbers).toList();
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a > b ? a : b);
  }

  List<double> _numbers(String s) {
    return RegExp(r'\d[\d,]*(?:\.\d{1,2})?')
        .allMatches(s)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '')))
        .whereType<double>()
        .toList();
  }

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  DateTime? _date(String text) {
    // yyyy-mm-dd or yyyy/mm/dd
    final iso = RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})').firstMatch(text);
    if (iso != null) {
      return _build(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }
    // dd/mm/yyyy or dd-mm-yy (day-first)
    final dmy = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})').firstMatch(text);
    if (dmy != null) {
      var year = int.parse(dmy.group(3)!);
      if (year < 100) year += 2000;
      return _build(year, int.parse(dmy.group(2)!), int.parse(dmy.group(1)!));
    }
    // dd Mon yyyy  /  Mon dd, yyyy
    final named = RegExp(
      r'(\d{1,2})\s+([A-Za-z]{3,})\.?\s+(\d{4})',
      caseSensitive: false,
    ).firstMatch(text);
    if (named != null) {
      final month = _months[named.group(2)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return _build(
          int.parse(named.group(3)!),
          month,
          int.parse(named.group(1)!),
        );
      }
    }
    return null;
  }

  DateTime? _build(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }

  static const _keywords = <TransactionCategory, List<String>>{
    TransactionCategory.food: [
      'restaurant', 'cafe', 'coffee', 'diner', 'pizza', 'burger',
      'kitchen', 'dining', 'bakery', 'bar & grill',
    ],
    TransactionCategory.groceries: [
      'grocery', 'supermarket', 'market', 'mart', 'grocer', 'bigbasket',
    ],
    TransactionCategory.transport: [
      'uber', 'ola', 'fuel', 'petrol', 'diesel', 'taxi', 'cab', 'metro',
    ],
    TransactionCategory.bills: [
      'electric', 'utility', 'broadband', 'recharge', 'telecom', 'bill',
    ],
    TransactionCategory.entertainment: [
      'cinema', 'movie', 'netflix', 'spotify', 'theatre', 'pvr',
    ],
    TransactionCategory.health: [
      'pharmacy', 'medical', 'hospital', 'clinic', 'chemist', 'apollo',
    ],
    TransactionCategory.shopping: [
      'mall', 'fashion', 'apparel', 'electronics', 'store', 'lifestyle',
    ],
  };

  TransactionCategory? _category(String lowerText) {
    for (final entry in _keywords.entries) {
      if (entry.value.any(lowerText.contains)) return entry.key;
    }
    return null;
  }
}
