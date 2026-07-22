import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:personal_finance_manager/features/budgets/domain/usecases/get_budgets.dart';
import 'package:personal_finance_manager/features/settings/data/export_service.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/entities/subscription.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_page.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/get_transactions.dart';

class _TxRepo implements TransactionRepository {
  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async => Right([
        Transaction(
          id: 't1',
          title: 'Coffee',
          amount: 200,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          paymentMethod: PaymentMethod.cash,
          date: DateTime(2026, 1, 1),
        ),
      ]);
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

class _BudgetRepo implements BudgetRepository {
  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async => const Right([
        Budget(id: 'b1', category: TransactionCategory.food, limit: 5000),
      ]);
  @override
  Future<Either<Failure, Unit>> saveBudget(Budget b) async => const Right(unit);
  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async =>
      const Right(unit);
}

class _SubRepo implements SubscriptionRepository {
  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptions() async =>
      Right([
        Subscription(
          id: 's1',
          name: 'Netflix',
          amount: 649,
          cycle: BillingCycle.monthly,
          nextBillingDate: DateTime(2026, 2, 1),
        ),
      ]);
  @override
  Future<Either<Failure, Unit>> saveSubscription(Subscription s) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> deleteSubscription(String id) async =>
      const Right(unit);
}

void main() {
  test('buildJson includes all data sections with correct counts', () async {
    final service = ExportDataService(
      getTransactions: GetTransactions(_TxRepo()),
      getBudgets: GetBudgets(_BudgetRepo()),
      getSubscriptions: GetSubscriptions(_SubRepo()),
    );

    final json = await service.buildJson(exportedAt: '2026-01-15T00:00:00.000');
    final doc = jsonDecode(json) as Map<String, dynamic>;

    expect(doc['exportedAt'], '2026-01-15T00:00:00.000');
    expect((doc['transactions'] as List).length, 1);
    expect((doc['budgets'] as List).length, 1);
    expect((doc['subscriptions'] as List).length, 1);
    expect((doc['transactions'] as List).first['title'], 'Coffee');
  });
}
