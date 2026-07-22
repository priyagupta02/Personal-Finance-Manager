import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets implements UseCase<List<Budget>, NoParams> {
  const GetBudgets(this._repository);

  final BudgetRepository _repository;

  @override
  Future<Either<Failure, List<Budget>>> call(NoParams params) =>
      _repository.getBudgets();
}
