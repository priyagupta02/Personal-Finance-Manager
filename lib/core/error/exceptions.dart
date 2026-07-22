/// Low-level exceptions thrown by data sources (storage, network, etc.).
///
/// These live in the data layer and are caught by repositories, which convert
/// them into [Failure]s before handing control back to the domain layer.
library;

class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a local data source (Hive / SharedPreferences) fails.
class CacheException extends AppException {
  const CacheException([super.message = 'A local storage error occurred.']);
}

/// Thrown when a remote API call fails.
class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred.']);
}

/// Thrown when authentication fails (bad credentials, expired session, etc.).
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

/// Thrown when input validation fails at the data layer.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed.']);
}
