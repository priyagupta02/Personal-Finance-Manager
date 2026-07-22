import 'package:dartz/dartz.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/auth/domain/entities/user.dart';
import 'package:personal_finance_manager/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] used by tests. Mirrors the real behavior
/// (register then login, wrong password fails) without touching storage.
class FakeAuthRepository implements AuthRepository {
  final Map<String, ({User user, String password})> _accounts = {};
  User? _session;
  String? _rememberedEmail;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final account = _accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      return const Left(AuthFailure('Incorrect email or password.'));
    }
    _session = account.user;
    _rememberedEmail = rememberMe ? email : null;
    return Right(account.user);
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email.toLowerCase())) {
      return const Left(AuthFailure('An account with this email exists.'));
    }
    final user = User(id: 'id-$email', name: name, email: email);
    _accounts[email.toLowerCase()] = (user: user, password: password);
    _session = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async =>
      const Left(AuthFailure('Google sign-in is not configured yet.'));

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(String email) async =>
      email.isEmpty
          ? const Left(ValidationFailure('Enter your email address.'))
          : const Right(unit);

  @override
  Future<Either<Failure, Unit>> logout() async {
    _session = null;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(_session);

  @override
  Future<Either<Failure, User>> updateProfile({required String name}) async {
    final current = _session;
    if (current == null) return const Left(AuthFailure('No user'));
    final updated = User(id: current.id, name: name, email: current.email);
    _session = updated;
    return Right(updated);
  }

  @override
  Future<String?> rememberedEmail() async => _rememberedEmail;

  /// Test helper to seed an existing account.
  void seedAccount(User user, String password) {
    _accounts[user.email.toLowerCase()] = (user: user, password: password);
  }
}
