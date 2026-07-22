import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Persists changes to an existing transaction.
class UpdateTransaction implements UseCase<Unit, Transaction> {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Transaction transaction) =>
      _repository.updateTransaction(transaction);
}
