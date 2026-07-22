import 'package:equatable/equatable.dart';

import 'transaction_enums.dart';

/// A single money movement — the core domain object of the app.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
    this.tags = const [],
    this.isRecurring = false,
    this.receiptPath,
  });

  final String id;
  final String title;

  /// Always a positive magnitude; [type] determines the sign in aggregates.
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String? note;
  final List<String> tags;
  final bool isRecurring;
  final String? receiptPath;

  /// Signed amount: positive for income, negative for expense.
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  Transaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? note,
    List<String>? tags,
    bool? isRecurring,
    String? receiptPath,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        category,
        paymentMethod,
        date,
        note,
        tags,
        isRecurring,
        receiptPath,
      ];
}
