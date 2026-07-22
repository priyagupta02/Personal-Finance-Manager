/// Named route paths for the whole app.
///
/// Declaring every planned screen here up front keeps navigation
/// self-documenting; screens are wired into [AppRouter] as they are built.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';
  static const String budgets = '/budgets';
  static const String analytics = '/analytics';
  static const String receiptScanner = '/receipt-scanner';
  static const String subscriptions = '/subscriptions';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
