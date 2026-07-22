import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/placeholder_page.dart';
import 'app_routes.dart';

/// Central navigation configuration built on `go_router`.
///
/// Routes currently resolve to a [PlaceholderPage] scaffold; each feature
/// replaces its own entry with a real screen in a dedicated commit.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            const PlaceholderPage(title: 'Personal Finance Manager'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
