import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed, centralized access to environment variables loaded from `.env`.
///
/// Reading env vars through this class (instead of `dotenv.env[...]` scattered
/// around the codebase) keeps configuration in one place and makes it trivial
/// to stub values in tests.
class EnvConfig {
  const EnvConfig._();

  /// Loads the `.env` file into memory. Must be awaited before [instance] is
  /// used — done once in `main()` during bootstrap.
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String _get(String key, {String fallback = ''}) =>
      dotenv.maybeGet(key) ?? fallback;

  static String get appName => _get('APP_NAME', fallback: 'Finance Manager');

  static String get appEnv => _get('APP_ENV', fallback: 'development');

  static bool get isProduction => appEnv == 'production';

  static String get apiBaseUrl =>
      _get('API_BASE_URL', fallback: 'https://api.example.com');

  static Duration get apiTimeout => Duration(
        milliseconds:
            int.tryParse(_get('API_TIMEOUT_MS', fallback: '30000')) ?? 30000,
      );

  static String get googleWebClientId => _get('GOOGLE_WEB_CLIENT_ID');
}
