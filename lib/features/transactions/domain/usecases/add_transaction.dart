import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Persists a new transaction.
class AddTransaction implements UseCase<Unit, Transaction> {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Transaction transaction) =>
      _repository.addTransaction(transaction);
}
