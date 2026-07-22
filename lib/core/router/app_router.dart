import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';

/// Central navigation configuration built on `go_router`.
///
/// The splash route is a real screen; login/home currently resolve to
/// [PlaceholderPage] and are replaced as those features land.
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
        builder: (context, state) => const PlaceholderPage(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Home Dashboard'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
