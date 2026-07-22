import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Starts the forgot-password flow for the given email.
class SendPasswordReset implements UseCase<Unit, String> {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendPasswordReset(email.trim());
}
