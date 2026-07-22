import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/transaction_repository.dart';

/// Deletes a transaction by id.
class DeleteTransaction implements UseCase<Unit, String> {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteTransaction(id);
}
