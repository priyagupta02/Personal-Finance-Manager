/// App-wide constant values that are not environment-specific.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Personal Finance Manager';

  /// Default page size for paginated lists (transaction list, etc.).
  static const int defaultPageSize = 20;

  /// Debounce interval for search inputs.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Minimum time the splash screen stays visible for the fade-in animation.
  static const Duration splashMinDuration = Duration(milliseconds: 2200);
}

/// Keys used for local key-value storage (SharedPreferences / secure storage).
/// Centralized to avoid typo-prone string literals across the codebase.
class StorageKeys {
  const StorageKeys._();

  static const String themeMode = 'theme_mode';
  static const String rememberMe = 'remember_me';
  static const String rememberedEmail = 'remembered_email';
  static const String authToken = 'auth_token';
  static const String currencyCode = 'currency_code';
  static const String onboardingComplete = 'onboarding_complete';
  static const String biometricEnabled = 'biometric_enabled';
}
