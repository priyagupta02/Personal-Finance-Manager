import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_enums.dart';

enum BudgetPeriod {
  weekly,
  monthly;

  String get label => switch (this) {
        BudgetPeriod.weekly => 'Weekly',
        BudgetPeriod.monthly => 'Monthly',
      };
}

/// A spending limit for a category over a period.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.period = BudgetPeriod.monthly,
  });

  final String id;
  final TransactionCategory category;
  final double limit;
  final BudgetPeriod period;

  @override
  List<Object?> get props => [id, category, limit, period];
}
