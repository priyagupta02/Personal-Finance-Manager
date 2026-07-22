import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:personal_finance_manager/features/budgets/domain/usecases/delete_budget.dart';
import 'package:personal_finance_manager/features/budgets/domain/usecases/get_budgets.dart';
import 'package:personal_finance_manager/features/budgets/domain/usecases/save_budget.dart';
import 'package:personal_finance_manager/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_page.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/get_transactions.dart';

class _FakeBudgetRepo implements BudgetRepository {
  _FakeBudgetRepo(this._budgets);
  List<Budget> _budgets;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async => Right(_budgets);

  @override
  Future<Either<Failure, Unit>> saveBudget(Budget b) async {
    _budgets = [..._budgets.where((x) => x.id != b.id), b];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async {
    _budgets = _budgets.where((x) => x.id != id).toList();
    return const Right(unit);
  }
}

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
  Transaction expense(
    TransactionCategory category,
    double amount,
    DateTime date,
  ) =>
      Transaction(
        id: '$category-$amount-$date',
        title: category.label,
        amount: amount,
        type: TransactionType.expense,
        category: category,
        paymentMethod: PaymentMethod.cash,
        date: date,
      );

  final now = DateTime(2026, 6, 15);

  BudgetCubit build(List<Budget> budgets, List<Transaction> txs) {
    final budgetRepo = _FakeBudgetRepo(budgets);
    final txRepo = _FakeTxRepo(txs);
    return BudgetCubit(
      getBudgets: GetBudgets(budgetRepo),
      getTransactions: GetTransactions(txRepo),
      saveBudget: SaveBudget(budgetRepo),
      deleteBudget: DeleteBudget(budgetRepo),
      now: now,
    );
  }

  test('computes spend for the current month and flags the alert threshold',
      () async {
    final cubit = build(
      const [
        Budget(
          id: 'food',
          category: TransactionCategory.food,
          limit: 6000,
          alertThreshold: 50,
        ),
      ],
      [
        expense(TransactionCategory.food, 4000, DateTime(2026, 6, 5)),
        expense(TransactionCategory.food, 1000, DateTime(2026, 5, 10)), // last month
      ],
    );

    await cubit.load();
    final food = cubit.state.items.single;

    expect(food.spent, 4000); // last month excluded
    expect(food.rolloverAmount, 0);
    expect(food.effectiveLimit, 6000);
    expect(food.alertReached, isTrue); // 66% >= 50%
    expect(food.isOverBudget, isFalse);
    await cubit.close();
  });

  test('rollover adds previous period leftover to the limit', () async {
    final cubit = build(
      const [
        Budget(
          id: 'shopping',
          category: TransactionCategory.shopping,
          limit: 5000,
          rollover: true,
        ),
      ],
      [
        expense(TransactionCategory.shopping, 2000, DateTime(2026, 6, 10)),
        expense(TransactionCategory.shopping, 500, DateTime(2026, 5, 20)),
      ],
    );

    await cubit.load();
    final shopping = cubit.state.items.single;

    expect(shopping.spent, 2000);
    expect(shopping.rolloverAmount, 4500); // 5000 - 500 leftover
    expect(shopping.effectiveLimit, 9500);
    await cubit.close();
  });

  test('save then delete a budget reloads the list', () async {
    final cubit = build(const [], const []);
    await cubit.load();
    expect(cubit.state.items, isEmpty);

    await cubit.saveBudget(
      const Budget(
        id: 'new',
        category: TransactionCategory.transport,
        limit: 2000,
      ),
    );
    expect(cubit.state.items.length, 1);

    await cubit.deleteBudget('new');
    expect(cubit.state.items, isEmpty);
    await cubit.close();
  });
}
