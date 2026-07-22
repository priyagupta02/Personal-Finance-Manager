import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
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
