import 'package:intl/intl.dart';

/// Formats monetary amounts for display.
///
/// Defaults to INR; currency/locale become user-configurable once the settings
/// feature lands, at which point the default here is the fallback.
class CurrencyFormatter {
  const CurrencyFormatter._();

  static const String defaultSymbol = '₹'; // ₹

  static String format(
    double amount, {
    String symbol = defaultSymbol,
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Signed, e.g. "+₹1,200" / "-₹850" — handy for transaction rows.
  static String formatSigned(double signedAmount, {String symbol = defaultSymbol}) {
    final sign = signedAmount >= 0 ? '+' : '-';
    return '$sign${format(signedAmount.abs(), symbol: symbol)}';
  }
}
