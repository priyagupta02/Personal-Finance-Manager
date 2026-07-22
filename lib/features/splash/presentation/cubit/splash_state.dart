part of 'splash_cubit.dart';

/// Where the splash screen should route once bootstrapping completes.
enum SplashDestination { login, home }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state while the fade-in animation plays and auth is being checked.
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Emitted once the destination has been resolved; the page navigates on this.
class SplashReady extends SplashState {
  const SplashReady(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}
