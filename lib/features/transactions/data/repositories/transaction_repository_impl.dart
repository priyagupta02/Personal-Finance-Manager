import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/entities/transaction_page.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._local);

  final TransactionLocalDataSource _local;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final items = await _local.getAll();
      return Right(items);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionPage>> queryTransactions(
    TransactionFilter filter,
  ) async {
    try {
      final all = await _local.getAll();
      final matched = all.where((t) => _matches(t, filter)).toList();
      _sort(matched, filter);

      final start = filter.page * filter.pageSize;
      final page = start >= matched.length
          ? <Transaction>[]
          : matched.skip(start).take(filter.pageSize).toList();
      final hasMore = start + page.length < matched.length;

      return Right(
        TransactionPage(
          items: page,
          hasMore: hasMore,
          totalCount: matched.length,
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  bool _matches(Transaction t, TransactionFilter f) {
    if (f.types.isNotEmpty && !f.types.contains(t.type)) return false;
    if (f.categories.isNotEmpty && !f.categories.contains(t.category)) {
      return false;
    }
    if (f.paymentMethods.isNotEmpty &&
        !f.paymentMethods.contains(t.paymentMethod)) {
      return false;
    }
    if (f.startDate != null && t.date.isBefore(f.startDate!)) return false;
    if (f.endDate != null && t.date.isAfter(f.endDate!)) return false;

    final term = f.searchTerm.trim().toLowerCase();
    if (term.isNotEmpty) {
      final haystack = [
        t.title,
        t.note ?? '',
        t.category.label,
        ...t.tags,
      ].join(' ').toLowerCase();
      if (!haystack.contains(term)) return false;
    }
    return true;
  }

  void _sort(List<Transaction> items, TransactionFilter f) {
    final ascending = f.sortOrder == SortOrder.ascending;
    items.sort((a, b) {
      final cmp = switch (f.sortField) {
        TransactionSortField.date => a.date.compareTo(b.date),
        TransactionSortField.amount => a.amount.compareTo(b.amount),
      };
      return ascending ? cmp : -cmp;
    });
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction transaction) =>
      _write(transaction);

  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction) =>
      _write(transaction);

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await _local.delete(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  Future<Either<Failure, Unit>> _write(Transaction transaction) async {
    try {
      await _local.save(TransactionModel.fromEntity(transaction));
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
