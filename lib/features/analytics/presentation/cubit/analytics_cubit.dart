import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';

part 'analytics_state.dart';

/// Loads transactions and derives every analytics view for the selected range:
/// category breakdown, income/expense trend, monthly comparison, category
/// trends, top categories, and text insights.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({
    required GetTransactions getTransactions,
    required DateTime now,
  })  : _getTransactions = getTransactions,
        _now = now,
        super(const AnalyticsState());

  final GetTransactions _getTransactions;
  final DateTime _now;

  static const int _topCategoryTrends = 3;

  Future<void> load() => _compute(state.range, state.customStart, state.customEnd);

  Future<void> rangeChanged(AnalyticsRange range) => _compute(range, null, null);

  Future<void> customRangeChanged(DateTime start, DateTime end) =>
      _compute(AnalyticsRange.custom, start, end);

  Future<void> _compute(
    AnalyticsRange range,
    DateTime? customStart,
    DateTime? customEnd,
  ) async {
    emit(state.copyWith(
      status: AnalyticsStatus.loading,
      range: range,
      customStart: customStart,
      customEnd: customEnd,
    ));

    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: AnalyticsStatus.error,
        errorMessage: failure.message,
      )),
      (all) {
        final (start, endExcl) = _resolveRange(range, customStart, customEnd);
        final months = _monthsBetween(start, endExcl);
        final inRange = all
            .where((t) => !t.date.isBefore(start) && t.date.isBefore(endExcl))
            .toList();

        emit(_buildState(range, customStart, customEnd, inRange, months));
      },
    );
  }

  AnalyticsState _buildState(
    AnalyticsRange range,
    DateTime? customStart,
    DateTime? customEnd,
    List<Transaction> txs,
    List<DateTime> months,
  ) {
    final expenses = txs.where((t) => t.type == TransactionType.expense);
    final totalExpense = expenses.fold<double>(0, (s, t) => s + t.amount);
    final totalIncome = txs
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);

    // Category breakdown (pie + top categories).
    final byCategory = <TransactionCategory, double>{};
    for (final t in expenses) {
      byCategory.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final breakdown = byCategory.entries
        .map((e) => CategoryAmount(
              category: e.key,
              amount: e.value,
              share: totalExpense == 0 ? 0 : e.value / totalExpense,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Monthly income/expense totals (trend line + comparison bar).
    final monthlyTotals = months.map((m) {
      bool inM(DateTime d) => d.year == m.year && d.month == m.month;
      return MonthlyTotals(
        month: m,
        income: txs
            .where((t) => t.type == TransactionType.income && inM(t.date))
            .fold<double>(0, (s, t) => s + t.amount),
        expense: txs
            .where((t) => t.type == TransactionType.expense && inM(t.date))
            .fold<double>(0, (s, t) => s + t.amount),
      );
    }).toList();

    // Category-wise spending over time for the top categories.
    final trends = breakdown.take(_topCategoryTrends).map((c) {
      final series = months.map((m) {
        return expenses
            .where((t) =>
                t.category == c.category &&
                t.date.year == m.year &&
                t.date.month == m.month)
            .fold<double>(0, (s, t) => s + t.amount);
      }).toList();
      return CategorySeries(category: c.category, monthlyExpense: series);
    }).toList();

    return state.copyWith(
      status: AnalyticsStatus.loaded,
      range: range,
      customStart: customStart,
      customEnd: customEnd,
      months: months,
      monthlyTotals: monthlyTotals,
      categoryBreakdown: breakdown,
      categoryTrends: trends,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      insights: _insights(totalIncome, totalExpense, breakdown, monthlyTotals),
    );
  }

  List<String> _insights(
    double income,
    double expense,
    List<CategoryAmount> breakdown,
    List<MonthlyTotals> monthly,
  ) {
    final insights = <String>[];

    if (expense == 0) {
      insights.add('No spending recorded in this period.');
      return insights;
    }

    if (breakdown.isNotEmpty) {
      final top = breakdown.first;
      insights.add(
        '${top.category.label} is your biggest expense at '
        '${(top.share * 100).toStringAsFixed(0)}% '
        '(${CurrencyFormatter.format(top.amount)}).',
      );
    }

    if (income > 0) {
      final rate = ((income - expense) / income * 100).clamp(-999, 100);
      insights.add(
        rate >= 0
            ? 'You saved ${rate.toStringAsFixed(0)}% of your income this period.'
            : 'You spent more than you earned this period.',
      );
    }

    // Month-over-month change on expenses.
    if (monthly.length >= 2) {
      final last = monthly.last.expense;
      final prev = monthly[monthly.length - 2].expense;
      if (prev > 0) {
        final change = (last - prev) / prev * 100;
        final month = DateFormat('MMMM').format(monthly.last.month);
        insights.add(
          change >= 0
              ? 'Spending in $month rose ${change.toStringAsFixed(0)}% vs the previous month.'
              : 'Spending in $month fell ${change.abs().toStringAsFixed(0)}% vs the previous month.',
        );
      }
    }

    return insights;
  }

  // --- Range helpers ------------------------------------------------------

  (DateTime, DateTime) _resolveRange(
    AnalyticsRange range,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    switch (range) {
      case AnalyticsRange.thisMonth:
        return (
          DateTime(_now.year, _now.month),
          DateTime(_now.year, _now.month + 1),
        );
      case AnalyticsRange.last3Months:
        return (
          DateTime(_now.year, _now.month - 2),
          DateTime(_now.year, _now.month + 1),
        );
      case AnalyticsRange.custom:
        final start = customStart ?? DateTime(_now.year, _now.month);
        final end = customEnd ?? _now;
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(end.year, end.month, end.day).add(const Duration(days: 1)),
        );
    }
  }

  List<DateTime> _monthsBetween(DateTime start, DateTime endExcl) {
    final months = <DateTime>[];
    var cursor = DateTime(start.year, start.month);
    final lastMonth = DateTime(endExcl.year, endExcl.month)
        .subtract(const Duration(days: 1));
    while (!cursor.isAfter(DateTime(lastMonth.year, lastMonth.month))) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return months;
  }
}
