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

/// The alert thresholds a budget can warn at, per the spec (50/75/90%).
const kAlertThresholds = [50, 75, 90];

/// A spending limit for a category over a period.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.period = BudgetPeriod.monthly,
    this.alertThreshold = 90,
    this.rollover = false,
  });

  final String id;
  final TransactionCategory category;
  final double limit;
  final BudgetPeriod period;

  /// Percent of the limit at which the user is alerted (one of [kAlertThresholds]).
  final int alertThreshold;

  /// When true, unspent budget from the previous period is added to this one.
  final bool rollover;

  Budget copyWith({
    TransactionCategory? category,
    double? limit,
    BudgetPeriod? period,
    int? alertThreshold,
    bool? rollover,
  }) {
    return Budget(
      id: id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      rollover: rollover ?? this.rollover,
    );
  }

  @override
  List<Object?> get props =>
      [id, category, limit, period, alertThreshold, rollover];
}
