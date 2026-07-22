import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/domain/usecases/get_budgets.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';

part 'home_state.dart';

/// Loads and derives all data shown on the dashboard: summary figures, the
/// recent list, the monthly spending series, and budget progress.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetTransactions getTransactions,
    required GetBudgets getBudgets,
  })  : _getTransactions = getTransactions,
        _getBudgets = getBudgets,
        super(const HomeState());

  final GetTransactions _getTransactions;
  final GetBudgets _getBudgets;

  static const int _recentCount = 5;
  static const int _chartMonths = 6;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final txResult = await _getTransactions(const NoParams());
    final budgetResult = await _getBudgets(const NoParams());

    await txResult.fold(
      (failure) async =>
          emit(state.copyWith(status: HomeStatus.error, errorMessage: failure.message)),
      (transactions) async {
        final budgets = budgetResult.getOrElse(() => <Budget>[]);
        emit(_buildState(transactions, budgets));
      },
    );
  }

  /// Pull-to-refresh simply reloads.
  Future<void> refresh() => load();

  HomeState _buildState(List<Transaction> transactions, List<Budget> budgets) {
    final now = DateTime.now();
    bool inMonth(DateTime d, DateTime month) =>
        d.year == month.year && d.month == month.month;

    final thisMonthTx =
        transactions.where((t) => inMonth(t.date, now)).toList();

    final monthlyIncome = _sum(
      thisMonthTx.where((t) => t.type == TransactionType.income),
    );
    final monthlyExpenses = _sum(
      thisMonthTx.where((t) => t.type == TransactionType.expense),
    );
    final totalBalance =
        transactions.fold<double>(0, (sum, t) => sum + t.signedAmount);
    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpenses) / monthlyIncome) * 100
        : 0.0;

    // Last N months of expense totals, oldest → newest.
    final monthlySpending = <MonthlySpending>[];
    for (var i = _chartMonths - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final total = _sum(
        transactions.where(
          (t) => t.type == TransactionType.expense && inMonth(t.date, month),
        ),
      );
      monthlySpending.add(MonthlySpending(month: month, total: total));
    }

    // Budget progress against this month's spending per category.
    final budgetProgress = budgets.map((b) {
      final spent = _sum(
        thisMonthTx.where(
          (t) => t.type == TransactionType.expense && t.category == b.category,
        ),
      );
      return BudgetProgress(budget: b, spent: spent);
    }).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    return HomeState(
      status: HomeStatus.loaded,
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      savingsRate: savingsRate,
      recentTransactions: transactions.take(_recentCount).toList(),
      monthlySpending: monthlySpending,
      budgetProgress: budgetProgress,
    );
  }

  double _sum(Iterable<Transaction> items) =>
      items.fold<double>(0, (sum, t) => sum + t.amount);
}
