import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_enums.dart';

/// The fields extracted from a receipt image by OCR + parsing. Any field may be
/// null when it could not be confidently detected; the user corrects them in
/// the review step.
class ScannedReceipt extends Equatable {
  const ScannedReceipt({
    this.amount,
    this.date,
    this.merchant,
    this.categorySuggestion,
    this.rawText = '',
  });

  final double? amount;
  final DateTime? date;
  final String? merchant;
  final TransactionCategory? categorySuggestion;

  /// The full recognized text, kept for debugging/manual reference.
  final String rawText;

  @override
  List<Object?> get props =>
      [amount, date, merchant, categorySuggestion, rawText];
}
