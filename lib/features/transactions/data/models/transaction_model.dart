import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';

/// Data-layer [Transaction] with JSON (de)serialization for local storage.
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.paymentMethod,
    required super.date,
    super.note,
    super.tags,
    super.isRecurring,
    super.receiptPath,
  });

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        title: t.title,
        amount: t.amount,
        type: t.type,
        category: t.category,
        paymentMethod: t.paymentMethod,
        date: t.date,
        note: t.note,
        tags: t.tags,
        isRecurring: t.isRecurring,
        receiptPath: t.receiptPath,
      );

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type'] as String),
        category:
            TransactionCategory.values.byName(json['category'] as String),
        paymentMethod:
            PaymentMethod.values.byName(json['paymentMethod'] as String),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        isRecurring: json['isRecurring'] as bool? ?? false,
        receiptPath: json['receiptPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'paymentMethod': paymentMethod.name,
        'date': date.toIso8601String(),
        'note': note,
        'tags': tags,
        'isRecurring': isRecurring,
        'receiptPath': receiptPath,
      };
}
