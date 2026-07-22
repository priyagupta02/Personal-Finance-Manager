import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:personal_finance_manager/core/di/injection.dart';
import 'package:personal_finance_manager/core/router/app_router.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/login.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/logout.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/register.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:personal_finance_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:personal_finance_manager/features/splash/domain/repositories/splash_repository.dart';
import 'package:personal_finance_manager/features/splash/presentation/cubit/splash_cubit.dart';

import 'features/auth/fake_auth_repository.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late AuthBloc authBloc;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Personal Finance Manager',
      packageName: 'in.primathon.personal_finance_manager',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    final splashRepository = MockSplashRepository();
    when(() => splashRepository.isAuthenticated())
        .thenAnswer((_) async => false);

    sl
      ..registerLazySingleton<SplashRepository>(() => splashRepository)
      ..registerFactory<SplashCubit>(
        () => SplashCubit(splashRepository, minSplashDuration: Duration.zero),
      );

    final authRepository = FakeAuthRepository();
    authBloc = AuthBloc(
      login: Login(authRepository),
      register: Register(authRepository),
      logout: Logout(authRepository),
      signInWithGoogle: SignInWithGoogle(authRepository),
      repository: authRepository,
    );
  });

  tearDown(() async {
    await authBloc.close();
    await sl.reset();
  });

  testWidgets('splash routes to the login screen when signed out',
      (tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );

    expect(find.text('Finance Manager'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
