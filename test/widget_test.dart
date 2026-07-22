import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/router/app_router.dart';

void main() {
  testWidgets('App boots to the splash placeholder', (tester) async {
    // Pump the router-driven app directly so the test does not depend on
    // env/DI bootstrap from main().
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.router),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personal Finance Manager'), findsOneWidget);
  });
}
