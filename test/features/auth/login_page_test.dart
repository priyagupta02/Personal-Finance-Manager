import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/login.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/logout.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/register.dart';
import 'package:personal_finance_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:personal_finance_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:personal_finance_manager/features/auth/presentation/pages/login_page.dart';

import 'fake_auth_repository.dart';

void main() {
  late AuthBloc authBloc;

  setUp(() {
    final repository = FakeAuthRepository();
    authBloc = AuthBloc(
      login: Login(repository),
      register: Register(repository),
      logout: Logout(repository),
      signInWithGoogle: SignInWithGoogle(repository),
      repository: repository,
    );
  });

  tearDown(() => authBloc.close());

  Widget wrap() => BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: LoginPage()),
      );

  testWidgets('shows validation errors for empty fields on submit',
      (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows an error for an invalid email format', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(
      find.byType(TextFormField).first,
      'not-an-email',
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('password field toggles visibility', (tester) async {
    await tester.pumpWidget(wrap());

    // Password is obscured by default -> "Show password" tooltip present.
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
