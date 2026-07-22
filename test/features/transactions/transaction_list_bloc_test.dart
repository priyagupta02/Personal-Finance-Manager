import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_page.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/query_transactions.dart';
import 'package:personal_finance_manager/features/transactions/presentation/bloc/transaction_list_bloc.dart';

/// Fake repo that honors page/pageSize and search term over a stored list.
class _FakeRepo implements TransactionRepository {
  _FakeRepo(this._items);
  List<Transaction> _items;

  @override
  Future<Either<Failure, TransactionPage>> queryTransactions(
    TransactionFilter f,
  ) async {
    var matched = _items;
    if (f.searchTerm.isNotEmpty) {
      matched = matched
          .where((t) =>
              t.title.toLowerCase().contains(f.searchTerm.toLowerCase()))
          .toList();
    }
    final start = f.page * f.pageSize;
    final page = start >= matched.length
        ? <Transaction>[]
        : matched.skip(start).take(f.pageSize).toList();
    return Right(TransactionPage(
      items: page,
      hasMore: start + page.length < matched.length,
      totalCount: matched.length,
    ));
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    _items = _items.where((t) => t.id != id).toList();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async =>
      Right(_items);
  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction t) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction t) async =>
      const Right(unit);
}

void main() {
  Transaction tx(String id) => Transaction(
        id: id,
        title: id,
        amount: 100,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        paymentMethod: PaymentMethod.cash,
        date: DateTime(2026, 1, 1),
      );

  TransactionListBloc build(List<Transaction> items) {
    final repo = _FakeRepo(items);
    return TransactionListBloc(
      queryTransactions: QueryTransactions(repo),
      deleteTransaction: DeleteTransaction(repo),
    );
  }

  blocTest<TransactionListBloc, TransactionListState>(
    'loads the first page on start',
    build: () => build([tx('a'), tx('b')]),
    act: (bloc) => bloc.add(const TransactionListStarted()),
    expect: () => [
      isA<TransactionListState>()
          .having((s) => s.status, 'status', TransactionListStatus.loading),
      isA<TransactionListState>()
          .having((s) => s.status, 'status', TransactionListStatus.success)
          .having((s) => s.transactions.length, 'count', 2)
          .having((s) => s.hasReachedMax, 'hasReachedMax', true),
    ],
  );

  blocTest<TransactionListBloc, TransactionListState>(
    'appends the next page on scroll',
    build: () => build([tx('a'), tx('b'), tx('c')]),
    act: (bloc) async {
      bloc.add(const TransactionFilterChanged(TransactionFilter(pageSize: 2)));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const TransactionListNextPageRequested());
    },
    skip: 3, // loading, success(page0), isLoadingMore
    expect: () => [
      isA<TransactionListState>()
          .having((s) => s.transactions.length, 'count', 3)
          .having((s) => s.hasReachedMax, 'hasReachedMax', true),
    ],
  );

  blocTest<TransactionListBloc, TransactionListState>(
    'removes a transaction on delete',
    build: () => build([tx('a'), tx('b')]),
    act: (bloc) async {
      bloc.add(const TransactionListStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const TransactionDeleted('a'));
    },
    expect: () => [
      isA<TransactionListState>()
          .having((s) => s.status, 'status', TransactionListStatus.loading),
      isA<TransactionListState>()
          .having((s) => s.transactions.length, 'count', 2),
      isA<TransactionListState>()
          .having((s) => s.transactions.map((t) => t.id), 'ids', ['b'])
          .having((s) => s.totalCount, 'total', 1),
    ],
  );

  blocTest<TransactionListBloc, TransactionListState>(
    'debounced search filters results',
    build: () => build([tx('apple'), tx('banana')]),
    act: (bloc) => bloc.add(const TransactionSearchChanged('apple')),
    wait: const Duration(milliseconds: 450),
    expect: () => [
      isA<TransactionListState>()
          .having((s) => s.status, 'status', TransactionListStatus.loading),
      isA<TransactionListState>()
          .having((s) => s.transactions.length, 'count', 1)
          .having((s) => s.transactions.single.id, 'id', 'apple'),
    ],
  );
}
