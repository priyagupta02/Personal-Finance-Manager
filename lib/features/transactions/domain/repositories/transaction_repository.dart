import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/transaction_filter.dart';
import '../entities/transaction_page.dart';

/// Contract for reading and mutating transactions.
///
/// The Add/Edit Transaction and Transaction List features build on the same
/// interface; the dashboard only needs [getTransactions].
abstract class TransactionRepository {
  /// Returns all transactions, newest first.
  Future<Either<Failure, List<Transaction>>> getTransactions();

  /// Returns a filtered, sorted, paginated page of transactions.
  Future<Either<Failure, TransactionPage>> queryTransactions(
    TransactionFilter filter,
  );

  Future<Either<Failure, Unit>> addTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String id);
}
