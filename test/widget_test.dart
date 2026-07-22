import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:personal_finance_manager/core/di/injection.dart';
import 'package:personal_finance_manager/core/router/app_router.dart';
import 'package:personal_finance_manager/features/splash/domain/repositories/splash_repository.dart';
import 'package:personal_finance_manager/features/splash/presentation/cubit/splash_cubit.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Personal Finance Manager',
      packageName: 'in.primathon.personal_finance_manager',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    final repository = MockSplashRepository();
    when(() => repository.isAuthenticated()).thenAnswer((_) async => false);

    // Register a zero-delay cubit so the splash resolves immediately.
    sl
      ..registerLazySingleton<SplashRepository>(() => repository)
      ..registerFactory<SplashCubit>(
        () => SplashCubit(repository, minSplashDuration: Duration.zero),
      );
  });

  tearDown(() => sl.reset());

  testWidgets('splash renders branding and routes to Login when signed out',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.router),
    );

    // First frame: splash branding is on screen.
    expect(find.text('Finance Manager'), findsOneWidget);

    // After bootstrap + animations settle, we land on the Login placeholder.
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}
