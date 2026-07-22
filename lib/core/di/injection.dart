import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password_cubit.dart';
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
  _initAuth();
  _initSplash();
}

void _initAuth() {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(
        prefs: sl<SharedPreferences>(),
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
    )
    ..registerLazySingleton(() => Login(sl<AuthRepository>()))
    ..registerLazySingleton(() => Register(sl<AuthRepository>()))
    ..registerLazySingleton(() => Logout(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()))
    ..registerLazySingleton(() => SendPasswordReset(sl<AuthRepository>()))
    // AuthBloc holds the app-wide session, so it is a singleton.
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        login: sl<Login>(),
        register: sl<Register>(),
        logout: sl<Logout>(),
        signInWithGoogle: sl<SignInWithGoogle>(),
        repository: sl<AuthRepository>(),
      ),
    )
    ..registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(sl<SendPasswordReset>()),
    );
}

void _initSplash() {
  sl
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(sl<FlutterSecureStorage>()),
    )
    // Cubit is per-use (factory) so each splash entry gets a fresh instance.
    ..registerFactory<SplashCubit>(() => SplashCubit(sl<SplashRepository>()));
}
