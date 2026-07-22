import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/sign_in_with_google.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns the app-wide authentication session and login/register/logout actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required Login login,
    required Register register,
    required Logout logout,
    required SignInWithGoogle signInWithGoogle,
    required AuthRepository repository,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _signInWithGoogle = signInWithGoogle,
        _repository = repository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final Login _login;
  final Register _register;
  final Logout _logout;
  final SignInWithGoogle _signInWithGoogle;
  final AuthRepository _repository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final rememberedEmail = await _repository.rememberedEmail();
    final result = await _repository.currentUser();
    result.fold(
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        rememberedEmail: rememberedEmail,
      )),
      (user) => emit(
        user == null
            ? state.copyWith(
                status: AuthStatus.unauthenticated,
                rememberedEmail: rememberedEmail,
              )
            : state.copyWith(
                status: AuthStatus.authenticated,
                user: user,
                rememberedEmail: rememberedEmail,
              ),
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _login(
      LoginParams(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );
    _emitAuthResult(result, emit);
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _register(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    _emitAuthResult(result, emit);
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _signInWithGoogle(const NoParams());
    _emitAuthResult(result, emit);
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _emitAuthResult(Either<Failure, User> result, Emitter<AuthState> emit) {
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      ),
    );
  }
}
