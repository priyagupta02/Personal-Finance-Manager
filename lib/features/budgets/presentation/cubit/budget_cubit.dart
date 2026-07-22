import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/save_budget.dart';

part 'budget_state.dart';

/// Loads budgets, computes actual spend per period (with optional rollover from
/// the previous period), and handles create/edit/delete.
class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit({
    required GetBudgets getBudgets,
    required GetTransactions getTransactions,
    required SaveBudget saveBudget,
    required DeleteBudget deleteBudget,
    required DateTime now,
  })  : _getBudgets = getBudgets,
        _getTransactions = getTransactions,
        _saveBudget = saveBudget,
        _deleteBudget = deleteBudget,
        _now = now,
        super(const BudgetState());

  final GetBudgets _getBudgets;
  final GetTransactions _getTransactions;
  final SaveBudget _saveBudget;
  final DeleteBudget _deleteBudget;
  final DateTime _now;

  Future<void> load() async {
    emit(state.copyWith(status: BudgetStatus.loading));

    final budgetResult = await _getBudgets(const NoParams());
    final txResult = await _getTransactions(const NoParams());

    final failure = budgetResult.fold((f) => f, (_) => null) ??
        txResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(
        status: BudgetStatus.error,
        errorMessage: failure.message,
      ));
      return;
    }

    final budgets = budgetResult.getOrElse(() => const []);
    final transactions = txResult.getOrElse(() => const []);

    final items = budgets.map((b) {
      final (curStart, curEnd) = _currentPeriod(b.period);
      final spent = _spent(transactions, b.category, curStart, curEnd);

      var rollover = 0.0;
      if (b.rollover) {
        final (prevStart, prevEnd) = _previousPeriod(b.period);
        final prevSpent = _spent(transactions, b.category, prevStart, prevEnd);
        rollover = (b.limit - prevSpent).clamp(0, double.infinity);
      }
      return BudgetView(budget: b, spent: spent, rolloverAmount: rollover);
    }).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    emit(state.copyWith(status: BudgetStatus.loaded, items: items));
  }

  Future<void> saveBudget(Budget budget) async {
    await _saveBudget(budget);
    await load();
  }

  Future<void> deleteBudget(String id) async {
    await _deleteBudget(id);
    await load();
  }

  // --- Period helpers -----------------------------------------------------

  (DateTime, DateTime) _currentPeriod(BudgetPeriod period) {
    if (period == BudgetPeriod.monthly) {
      final start = DateTime(_now.year, _now.month);
      final end = DateTime(_now.year, _now.month + 1);
      return (start, end);
    }
    final start = _startOfWeek(_now);
    return (start, start.add(const Duration(days: 7)));
  }

  (DateTime, DateTime) _previousPeriod(BudgetPeriod period) {
    if (period == BudgetPeriod.monthly) {
      final start = DateTime(_now.year, _now.month - 1);
      final end = DateTime(_now.year, _now.month);
      return (start, end);
    }
    final start = _startOfWeek(_now).subtract(const Duration(days: 7));
    return (start, start.add(const Duration(days: 7)));
  }

  DateTime _startOfWeek(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  double _spent(
    List<Transaction> txs,
    TransactionCategory category,
    DateTime start,
    DateTime end,
  ) {
    return txs
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == category &&
            !t.date.isBefore(start) &&
            t.date.isBefore(end))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }
}
