import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';

/// Global service locator.
///
/// Feature modules register their own data sources, repositories, use cases,
/// and BLoCs here via dedicated `init...()` helpers, keeping wiring explicit
/// and testable (tests can register fakes against the same locator).
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // --- External / core singletons ---------------------------------------
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // --- Feature registrations ---------------------------------------------
  _initSplash();
}

void _initSplash() {
  sl
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(sl<FlutterSecureStorage>()),
    )
    // Cubit is per-use (factory) so each splash entry gets a fresh instance.
    ..registerFactory<SplashCubit>(() => SplashCubit(sl<SplashRepository>()));
}
