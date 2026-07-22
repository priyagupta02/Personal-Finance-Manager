import 'package:equatable/equatable.dart';

import 'transaction_enums.dart';

/// A partially-filled Add Transaction form, persisted so the user can leave and
/// return without losing input. Amount is kept as raw text since the form may
/// hold an incomplete value.
class TransactionDraft extends Equatable {
  const TransactionDraft({
    required this.type,
    required this.amountText,
    required this.category,
    required this.paymentMethod,
    required this.date,
    required this.description,
    required this.tags,
    required this.isRecurring,
    this.receiptPath,
  });

  final TransactionType type;
  final String amountText;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String description;
  final List<String> tags;
  final bool isRecurring;
  final String? receiptPath;

  @override
  List<Object?> get props => [
        type,
        amountText,
        category,
        paymentMethod,
        date,
        description,
        tags,
        isRecurring,
        receiptPath,
      ];
}
