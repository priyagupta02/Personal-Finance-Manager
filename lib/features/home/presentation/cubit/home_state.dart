part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

/// Expense total for a single month, used by the spending chart.
class MonthlySpending extends Equatable {
  const MonthlySpending({required this.month, required this.total});

  final DateTime month;
  final double total;

  @override
  List<Object?> get props => [month, total];
}

/// A budget paired with how much has been spent against it this month.
class BudgetProgress extends Equatable {
  const BudgetProgress({required this.budget, required this.spent});

  final Budget budget;
  final double spent;

  double get ratio => budget.limit <= 0 ? 0 : (spent / budget.limit);
  double get remaining => budget.limit - spent;
  bool get isOverBudget => spent > budget.limit;

  @override
  List<Object?> get props => [budget, spent];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpenses = 0,
    this.savingsRate = 0,
    this.recentTransactions = const [],
    this.monthlySpending = const [],
    this.budgetProgress = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  /// Percentage of income kept as savings this month (0–100).
  final double savingsRate;

  final List<Transaction> recentTransactions;
  final List<MonthlySpending> monthlySpending;
  final List<BudgetProgress> budgetProgress;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsRate,
    List<Transaction>? recentTransactions,
    List<MonthlySpending>? monthlySpending,
    List<BudgetProgress>? budgetProgress,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      savingsRate: savingsRate ?? this.savingsRate,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      budgetProgress: budgetProgress ?? this.budgetProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalBalance,
        monthlyIncome,
        monthlyExpenses,
        savingsRate,
        recentTransactions,
        monthlySpending,
        budgetProgress,
        errorMessage,
      ];
}
