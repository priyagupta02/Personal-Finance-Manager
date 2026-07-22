import 'package:flutter/material.dart';

/// Whether a transaction adds to or subtracts from the balance.
enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
      };
}

/// How a transaction was paid for.
enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer;

  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.card => 'Card',
        PaymentMethod.upi => 'UPI',
        PaymentMethod.bankTransfer => 'Bank Transfer',
      };

  IconData get icon => switch (this) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.card => Icons.credit_card,
        PaymentMethod.upi => Icons.qr_code_2,
        PaymentMethod.bankTransfer => Icons.account_balance_outlined,
      };
}

/// Spending/earning category. Carries its own icon and color so the UI has a
/// single source of truth for how each category is presented.
enum TransactionCategory {
  food,
  groceries,
  shopping,
  transport,
  bills,
  entertainment,
  health,
  education,
  salary,
  investment,
  other;

  String get label => switch (this) {
        TransactionCategory.food => 'Food & Dining',
        TransactionCategory.groceries => 'Groceries',
        TransactionCategory.shopping => 'Shopping',
        TransactionCategory.transport => 'Transport',
        TransactionCategory.bills => 'Bills & Utilities',
        TransactionCategory.entertainment => 'Entertainment',
        TransactionCategory.health => 'Health',
        TransactionCategory.education => 'Education',
        TransactionCategory.salary => 'Salary',
        TransactionCategory.investment => 'Investment',
        TransactionCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        TransactionCategory.food => Icons.restaurant,
        TransactionCategory.groceries => Icons.local_grocery_store,
        TransactionCategory.shopping => Icons.shopping_bag,
        TransactionCategory.transport => Icons.directions_car,
        TransactionCategory.bills => Icons.receipt_long,
        TransactionCategory.entertainment => Icons.movie,
        TransactionCategory.health => Icons.favorite,
        TransactionCategory.education => Icons.school,
        TransactionCategory.salary => Icons.account_balance_wallet,
        TransactionCategory.investment => Icons.trending_up,
        TransactionCategory.other => Icons.category,
      };

  Color get color => switch (this) {
        TransactionCategory.food => const Color(0xFFE0533D),
        TransactionCategory.groceries => const Color(0xFF2E9E5B),
        TransactionCategory.shopping => const Color(0xFF8E5BE0),
        TransactionCategory.transport => const Color(0xFF3D8BE0),
        TransactionCategory.bills => const Color(0xFFF2A44E),
        TransactionCategory.entertainment => const Color(0xFFE05B9E),
        TransactionCategory.health => const Color(0xFFE03D5B),
        TransactionCategory.education => const Color(0xFF5B8EE0),
        TransactionCategory.salary => const Color(0xFF2E9E5B),
        TransactionCategory.investment => const Color(0xFF2E7D6B),
        TransactionCategory.other => const Color(0xFF7A8A86),
      };
}
