import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Authentication contract the presentation layer depends on.
///
/// The concrete implementation currently talks to a local fake backend, but
/// this interface is backend-agnostic so a real API can be swapped in.
abstract class AuthRepository {
  /// Signs in with email/password. When [rememberMe] is true the email is
  /// persisted so it can be pre-filled next launch.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Registers a new account and signs the user in.
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in with Google (bonus). Returns [AuthFailure] until configured.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Triggers a password-reset flow for [email].
  Future<Either<Failure, Unit>> sendPasswordReset(String email);

  /// Clears the persisted session.
  Future<Either<Failure, Unit>> logout();

  /// The currently signed-in user, or `null` if the session is empty.
  Future<Either<Failure, User?>> currentUser();

  /// The remembered email from a previous "Remember Me" login, if any.
  Future<String?> rememberedEmail();
}
