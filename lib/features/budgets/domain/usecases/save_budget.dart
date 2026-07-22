import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Creates or updates a budget (upsert by id).
class SaveBudget implements UseCase<Unit, Budget> {
  const SaveBudget(this._repository);

  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Budget budget) =>
      _repository.saveBudget(budget);
}
