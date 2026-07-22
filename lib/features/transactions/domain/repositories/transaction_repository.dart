import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

/// Contract for reading and mutating transactions.
///
/// The Add/Edit Transaction and Transaction List features build on the same
/// interface; the dashboard only needs [getTransactions] for now.
abstract class TransactionRepository {
  /// Returns all transactions, newest first.
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, Unit>> addTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String id);
}
