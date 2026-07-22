import '../../domain/entities/transaction_draft.dart';
import '../../domain/entities/transaction_enums.dart';

/// Serializable [TransactionDraft] for local persistence.
class TransactionDraftModel extends TransactionDraft {
  const TransactionDraftModel({
    required super.type,
    required super.amountText,
    required super.category,
    required super.paymentMethod,
    required super.date,
    required super.description,
    required super.tags,
    required super.isRecurring,
    super.receiptPath,
  });

  factory TransactionDraftModel.fromEntity(TransactionDraft d) =>
      TransactionDraftModel(
        type: d.type,
        amountText: d.amountText,
        category: d.category,
        paymentMethod: d.paymentMethod,
        date: d.date,
        description: d.description,
        tags: d.tags,
        isRecurring: d.isRecurring,
        receiptPath: d.receiptPath,
      );

  factory TransactionDraftModel.fromJson(Map<String, dynamic> json) =>
      TransactionDraftModel(
        type: TransactionType.values.byName(json['type'] as String),
        amountText: json['amountText'] as String,
        category:
            TransactionCategory.values.byName(json['category'] as String),
        paymentMethod:
            PaymentMethod.values.byName(json['paymentMethod'] as String),
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        isRecurring: json['isRecurring'] as bool? ?? false,
        receiptPath: json['receiptPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'amountText': amountText,
        'category': category.name,
        'paymentMethod': paymentMethod.name,
        'date': date.toIso8601String(),
        'description': description,
        'tags': tags,
        'isRecurring': isRecurring,
        'receiptPath': receiptPath,
      };
}
