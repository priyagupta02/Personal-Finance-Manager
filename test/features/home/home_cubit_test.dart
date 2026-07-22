import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:personal_finance_manager/features/budgets/domain/usecases/get_budgets.dart';
import 'package:personal_finance_manager/features/home/presentation/cubit/home_cubit.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/get_transactions.dart';

class _FakeTxRepo implements TransactionRepository {
  _FakeTxRepo(this._items);
  final List<Transaction> _items;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return Right(sorted);
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction t) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction t) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async =>
      const Right(unit);
}

class _FakeBudgetRepo implements BudgetRepository {
  _FakeBudgetRepo(this._items);
  final List<Budget> _items;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async => Right(_items);
  @override
  Future<Either<Failure, Unit>> saveBudget(Budget b) async => const Right(unit);
  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async =>
      const Right(unit);
}

void main() {
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1, 15);

  Transaction tx({
    required String id,
    required double amount,
    required TransactionType type,
    TransactionCategory category = TransactionCategory.food,
    DateTime? date,
  }) =>
      Transaction(
        id: id,
        title: id,
        amount: amount,
        type: type,
        category: category,
        paymentMethod: PaymentMethod.cash,
        date: date ?? now,
      );

  HomeCubit build(List<Transaction> txs, List<Budget> budgets) => HomeCubit(
        getTransactions: GetTransactions(_FakeTxRepo(txs)),
        getBudgets: GetBudgets(_FakeBudgetRepo(budgets)),
      );

  test('computes balance, monthly income/expenses and savings rate', () async {
    final cubit = build(
      [
        tx(id: 'i1', amount: 1000, type: TransactionType.income),
        tx(id: 'e1', amount: 400, type: TransactionType.expense),
        tx(id: 'e2', amount: 100, type: TransactionType.expense, date: lastMonth),
      ],
      const [],
    );

    await cubit.load();
    final s = cubit.state;

    expect(s.status, HomeStatus.loaded);
    expect(s.totalBalance, 500); // 1000 - 400 - 100
    expect(s.monthlyIncome, 1000);
    expect(s.monthlyExpenses, 400); // last month's 100 excluded
    expect(s.savingsRate, closeTo(60, 0.001)); // (1000-400)/1000*100
    await cubit.close();
  });

  test('recent transactions are limited to five, newest first', () async {
    final txs = [
      for (var i = 0; i < 8; i++)
        tx(
          id: 'e$i',
          amount: 10.0 * i,
          type: TransactionType.expense,
          date: now.subtract(Duration(days: i)),
        ),
    ];
    final cubit = build(txs, const []);

    await cubit.load();

    expect(cubit.state.recentTransactions.length, 5);
    expect(cubit.state.recentTransactions.first.id, 'e0'); // most recent
    await cubit.close();
  });

  test('budget progress pairs spend with limit for the month', () async {
    final cubit = build(
      [
        tx(
          id: 'e1',
          amount: 400,
          type: TransactionType.expense,
          category: TransactionCategory.food,
        ),
      ],
      const [
        Budget(id: 'b1', category: TransactionCategory.food, limit: 500),
      ],
    );

    await cubit.load();
    final progress = cubit.state.budgetProgress.single;

    expect(progress.spent, 400);
    expect(progress.ratio, closeTo(0.8, 0.001));
    expect(progress.isOverBudget, isFalse);
    await cubit.close();
  });
}
