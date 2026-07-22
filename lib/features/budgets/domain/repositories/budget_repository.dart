import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

/// Contract for reading and mutating budgets. The Budget Management feature
/// extends usage of this; the dashboard only reads via [getBudgets].
abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();

  Future<Either<Failure, Unit>> saveBudget(Budget budget);

  Future<Either<Failure, Unit>> deleteBudget(String id);
}
