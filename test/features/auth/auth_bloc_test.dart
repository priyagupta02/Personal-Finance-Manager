import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/features/auth/domain/entities/user.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/login.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/logout.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/register.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:personal_finance_manager/features/auth/presentation/bloc/auth_bloc.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  AuthBloc buildBloc() => AuthBloc(
        login: Login(repository),
        register: Register(repository),
        logout: Logout(repository),
        signInWithGoogle: SignInWithGoogle(repository),
        repository: repository,
      );

  setUp(() => repository = FakeAuthRepository());

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated on successful login',
      setUp: () => repository.seedAccount(
        const User(id: '1', name: 'Priya', email: 'priya@example.com'),
        'Passw0rd',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'priya@example.com',
        password: 'Passw0rd',
        rememberMe: true,
      )),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.email, 'email', 'priya@example.com')
            .having((s) => s.isSubmitting, 'isSubmitting', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error on wrong password',
      setUp: () => repository.seedAccount(
        const User(id: '1', name: 'Priya', email: 'priya@example.com'),
        'Passw0rd',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'priya@example.com',
        password: 'wrong',
        rememberMe: false,
      )),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'error', isNotNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'registers a new account and authenticates',
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        name: 'New User',
        email: 'new@example.com',
        password: 'Passw0rd',
      )),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.email, 'email', 'new@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'logout returns to unauthenticated',
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.user, 'user', isNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'google sign-in surfaces a not-configured error',
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'error', isNotNull),
      ],
    );
  });
}
