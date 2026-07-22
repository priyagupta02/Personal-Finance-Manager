part of 'auth_bloc.dart';

/// High-level session status used by the router/UI to decide what to show.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.rememberedEmail,
  });

  final AuthStatus status;
  final User? user;

  /// True while a login/register/google request is in flight (drives spinners
  /// and disabled buttons).
  final bool isSubmitting;

  /// Last error from a failed action; consumed by the UI to show a message.
  final String? errorMessage;

  /// Email persisted via "Remember Me" to pre-fill the login form.
  final String? rememberedEmail;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isSubmitting,
    String? errorMessage,
    String? rememberedEmail,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rememberedEmail: rememberedEmail ?? this.rememberedEmail,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, isSubmitting, errorMessage, rememberedEmail];
}
