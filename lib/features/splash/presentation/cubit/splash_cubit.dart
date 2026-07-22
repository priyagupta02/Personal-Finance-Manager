import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/splash_repository.dart';

part 'splash_state.dart';

/// Drives the splash screen: waits a minimum duration (so the fade-in logo is
/// visible), checks the persisted session, then resolves where to navigate.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._repository, {
    Duration minSplashDuration = AppConstants.splashMinDuration,
  })  : _minSplashDuration = minSplashDuration,
        super(const SplashInitial());

  final SplashRepository _repository;

  /// Minimum time the splash stays visible. Injectable so tests can pass
  /// [Duration.zero] instead of waiting the real duration.
  final Duration _minSplashDuration;

  Future<void> bootstrap() async {
    // Run the auth check and the minimum splash delay concurrently so the
    // screen is never shown for less than [_minSplashDuration] but also never
    // longer than necessary.
    final results = await Future.wait([
      _repository.isAuthenticated(),
      Future<void>.delayed(_minSplashDuration),
    ]);

    final isAuthenticated = results.first as bool;
    emit(
      SplashReady(
        isAuthenticated ? SplashDestination.home : SplashDestination.login,
      ),
    );
  }
}
