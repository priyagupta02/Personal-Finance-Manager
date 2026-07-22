part of 'forgot_password_cubit.dart';

enum ForgotPasswordStatus { idle, submitting, success, failure }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.idle,
    this.message,
  });

  final ForgotPasswordStatus status;
  final String? message;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? message,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
