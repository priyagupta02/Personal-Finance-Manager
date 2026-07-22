import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.limit,
    super.period,
    super.alertThreshold,
    super.rollover,
  });

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
        id: b.id,
        category: b.category,
        limit: b.limit,
        period: b.period,
        alertThreshold: b.alertThreshold,
        rollover: b.rollover,
      );

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] as String,
        category:
            TransactionCategory.values.byName(json['category'] as String),
        limit: (json['limit'] as num).toDouble(),
        period: BudgetPeriod.values.byName(json['period'] as String),
        alertThreshold: json['alertThreshold'] as int? ?? 90,
        rollover: json['rollover'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'limit': limit,
        'period': period.name,
        'alertThreshold': alertThreshold,
        'rollover': rollover,
      };
}
