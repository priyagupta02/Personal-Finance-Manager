import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/budget_repository.dart';

/// Deletes a budget by id.
class DeleteBudget implements UseCase<Unit, String> {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteBudget(id);
}
