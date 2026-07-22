import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/transactions/presentation/pages/transaction_list_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';

/// Central navigation configuration built on `go_router`.
///
/// Splash, auth, and the home dashboard are real screens. The routes the
/// dashboard links to (transactions, add, analytics, etc.) are placeholders
/// replaced as each feature lands.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      // --- Placeholder routes (replaced by their features) -----------------
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionListPage(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Add Transaction'),
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Edit Transaction'),
      ),
      GoRoute(
        path: AppRoutes.budgets,
        builder: (context, state) => const PlaceholderPage(title: 'Budgets'),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const PlaceholderPage(title: 'Analytics'),
      ),
      GoRoute(
        path: AppRoutes.receiptScanner,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Receipt Scanner'),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Subscriptions'),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const PlaceholderPage(title: 'Profile'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const PlaceholderPage(title: 'Settings'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
