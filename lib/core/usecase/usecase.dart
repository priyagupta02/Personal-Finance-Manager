import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base contract for a single unit of business logic.
///
/// Every use case takes [Params] and returns `Either<Failure, Type>`, giving
/// a uniform, testable shape across the whole domain layer.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use this as [Params] for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
