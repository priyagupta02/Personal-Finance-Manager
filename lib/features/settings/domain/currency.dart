import 'package:equatable/equatable.dart';

/// A supported display currency.
class Currency extends Equatable {
  const Currency({required this.code, required this.symbol, required this.name});

  final String code;
  final String symbol;
  final String name;

  @override
  List<Object?> get props => [code];
}

/// Default currency used before the user picks one.
const kDefaultCurrency = Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee');

/// Currencies the user can choose from (10+ to support the multi-currency goal).
const kSupportedCurrencies = <Currency>[
  kDefaultCurrency,
  Currency(code: 'USD', symbol: r'$', name: 'US Dollar'),
  Currency(code: 'EUR', symbol: '€', name: 'Euro'),
  Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  Currency(code: 'AUD', symbol: r'A$', name: 'Australian Dollar'),
  Currency(code: 'CAD', symbol: r'C$', name: 'Canadian Dollar'),
  Currency(code: 'SGD', symbol: r'S$', name: 'Singapore Dollar'),
  Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
];

Currency currencyForCode(String code) => kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
