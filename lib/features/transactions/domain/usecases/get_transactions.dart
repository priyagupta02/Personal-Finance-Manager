import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Fetches all transactions (newest first).
class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) =>
      _repository.getTransactions();
}
