import 'package:equatable/equatable.dart';

/// Domain-level representation of something that went wrong.
///
/// Use cases return `Either<Failure, T>` (via `dartz`) so the presentation
/// layer can handle errors without try/catch and without knowing about the
/// low-level [AppException] types from the data layer.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local data.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please check your input.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
