import 'package:intl/intl.dart';

/// Formats monetary amounts for display.
///
/// The active currency symbol is set once from the user's settings
/// ([setCurrency]) and used as the default for all formatting.
class CurrencyFormatter {
  const CurrencyFormatter._();

  static const String defaultSymbol = '₹';

  static String _activeSymbol = defaultSymbol;

  /// The currently selected currency symbol.
  static String get activeSymbol => _activeSymbol;

  /// Updates the active currency; called by settings on load/change.
  static void setCurrency(String symbol) => _activeSymbol = symbol;

  static String format(
    double amount, {
    String? symbol,
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol ?? _activeSymbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Signed, e.g. "+₹1,200" / "-₹850" — handy for transaction rows.
  static String formatSigned(double signedAmount, {String? symbol}) {
    final sign = signedAmount >= 0 ? '+' : '-';
    return '$sign${format(signedAmount.abs(), symbol: symbol)}';
  }
}
