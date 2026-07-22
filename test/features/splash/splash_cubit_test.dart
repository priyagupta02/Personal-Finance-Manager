import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_finance_manager/features/splash/domain/repositories/splash_repository.dart';
import 'package:personal_finance_manager/features/splash/presentation/cubit/splash_cubit.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository repository;

  setUp(() => repository = MockSplashRepository());

  SplashCubit buildCubit() =>
      SplashCubit(repository, minSplashDuration: Duration.zero);

  group('SplashCubit', () {
    test('initial state is SplashInitial', () {
      expect(buildCubit().state, const SplashInitial());
    });

    blocTest<SplashCubit, SplashState>(
      'routes to home when a session exists',
      setUp: () =>
          when(() => repository.isAuthenticated()).thenAnswer((_) async => true),
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => const [SplashReady(SplashDestination.home)],
    );

    blocTest<SplashCubit, SplashState>(
      'routes to login when no session exists',
      setUp: () => when(() => repository.isAuthenticated())
          .thenAnswer((_) async => false),
      build: buildCubit,
      act: (cubit) => cubit.bootstrap(),
      expect: () => const [SplashReady(SplashDestination.login)],
    );
  });
}
