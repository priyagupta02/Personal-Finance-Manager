import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_page.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/get_transactions.dart';

class _FakeTxRepo implements TransactionRepository {
  _FakeTxRepo(this._items);
  final List<Transaction> _items;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async =>
      Right(_items);
  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction t) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction t) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async =>
      const Right(unit);
  @override
  Future<Either<Failure, TransactionPage>> queryTransactions(
          TransactionFilter f) async =>
      const Right(TransactionPage(items: [], hasMore: false, totalCount: 0));
}

void main() {
  final now = DateTime(2026, 6, 15);

  Transaction t(
    TransactionType type,
    TransactionCategory category,
    double amount,
    DateTime date,
  ) =>
      Transaction(
        id: '$category-$amount-$date',
        title: category.label,
        amount: amount,
        type: type,
        category: category,
        paymentMethod: PaymentMethod.cash,
        date: date,
      );

  final txs = [
    t(TransactionType.income, TransactionCategory.salary, 10000, DateTime(2026, 6, 1)),
    t(TransactionType.expense, TransactionCategory.food, 3000, DateTime(2026, 6, 5)),
    t(TransactionType.expense, TransactionCategory.shopping, 1000, DateTime(2026, 6, 10)),
    t(TransactionType.expense, TransactionCategory.food, 2000, DateTime(2026, 5, 5)),
    t(TransactionType.expense, TransactionCategory.transport, 500, DateTime(2026, 4, 5)),
  ];

  AnalyticsCubit build() =>
      AnalyticsCubit(getTransactions: GetTransactions(_FakeTxRepo(txs)), now: now);

  test('default range (last 3 months) aggregates category breakdown', () async {
    final cubit = build();
    await cubit.load();
    final s = cubit.state;

    expect(s.status, AnalyticsStatus.loaded);
    expect(s.months.length, 3); // Apr, May, Jun
    expect(s.totalIncome, 10000);
    expect(s.totalExpense, 6500);
    expect(s.categoryBreakdown.first.category, TransactionCategory.food);
    expect(s.categoryBreakdown.first.amount, 5000); // 3000 + 2000
    await cubit.close();
  });

  test('monthly totals capture the current month figures', () async {
    final cubit = build();
    await cubit.load();
    final june = cubit.state.monthlyTotals
        .firstWhere((m) => m.month.month == 6 && m.month.year == 2026);
    expect(june.income, 10000);
    expect(june.expense, 4000); // 3000 + 1000
    await cubit.close();
  });

  test('switching to This Month narrows the window', () async {
    final cubit = build();
    await cubit.load();
    await cubit.rangeChanged(AnalyticsRange.thisMonth);
    final s = cubit.state;

    expect(s.range, AnalyticsRange.thisMonth);
    expect(s.months.length, 1);
    expect(s.totalExpense, 4000); // only June
    await cubit.close();
  });

  test('produces insights', () async {
    final cubit = build();
    await cubit.load();
    expect(cubit.state.insights, isNotEmpty);
    expect(cubit.state.insights.first, contains('Food'));
    await cubit.close();
  });
}
