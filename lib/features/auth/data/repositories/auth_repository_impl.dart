import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final user = await _local.authenticate(email: email, password: password);
      await _local.cacheSession(user, _generateToken());
      await _local.setRememberedEmail(rememberMe ? email : null);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _local.register(
        name: name,
        email: email,
        password: password,
      );
      await _local.cacheSession(user, _generateToken());
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    // Bonus: requires Firebase/Google configuration. Fails gracefully until
    // GOOGLE_WEB_CLIENT_ID is wired up.
    return const Left(
      AuthFailure('Google sign-in is not configured yet.'),
    );
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(String email) async {
    // No email backend in this build; simulate a successful request so the UI
    // flow can be demonstrated end to end.
    if (email.isEmpty) {
      return const Left(ValidationFailure('Enter your email address.'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearSession();
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Could not sign out. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, User?>> currentUser() async {
    try {
      final UserModel? user = await _local.getCurrentUser();
      return Right(user);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<String?> rememberedEmail() async => _local.getRememberedEmail();

  String _generateToken() {
    final rng = Random.secure();
    final bytes = List<int>.generate(24, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }
}
