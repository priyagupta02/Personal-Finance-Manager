part of 'budget_cubit.dart';

enum BudgetStatus { initial, loading, loaded, error }

/// A budget paired with its computed spend for the current period and any
/// rolled-over amount from the previous period.
class BudgetView extends Equatable {
  const BudgetView({
    required this.budget,
    required this.spent,
    required this.rolloverAmount,
  });

  final Budget budget;
  final double spent;

  /// Unspent amount carried over from the previous period (0 when rollover off).
  final double rolloverAmount;

  double get effectiveLimit => budget.limit + rolloverAmount;
  double get remaining => effectiveLimit - spent;
  double get ratio => effectiveLimit <= 0 ? 0 : spent / effectiveLimit;
  bool get isOverBudget => spent > effectiveLimit;

  /// True once spend crosses the budget's configured alert threshold.
  bool get alertReached => ratio * 100 >= budget.alertThreshold;

  @override
  List<Object?> get props => [budget, spent, rolloverAmount];
}

class BudgetState extends Equatable {
  const BudgetState({
    this.status = BudgetStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final BudgetStatus status;
  final List<BudgetView> items;
  final String? errorMessage;

  double get totalLimit =>
      items.fold(0, (sum, i) => sum + i.effectiveLimit);
  double get totalSpent => items.fold(0, (sum, i) => sum + i.spent);
  double get totalRemaining => (totalLimit - totalSpent).clamp(0, double.infinity);

  BudgetState copyWith({
    BudgetStatus? status,
    List<BudgetView>? items,
    String? errorMessage,
  }) {
    return BudgetState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
