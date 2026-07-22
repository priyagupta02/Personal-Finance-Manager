import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_password_reset.dart';

part 'forgot_password_state.dart';

/// Handles the isolated forgot-password flow, separate from [AuthBloc] since it
/// does not affect the app-wide session.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._sendPasswordReset)
      : super(const ForgotPasswordState());

  final SendPasswordReset _sendPasswordReset;

  Future<void> submit(String email) async {
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));
    final result = await _sendPasswordReset(email);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(status: ForgotPasswordStatus.success),
      ),
    );
  }
}
