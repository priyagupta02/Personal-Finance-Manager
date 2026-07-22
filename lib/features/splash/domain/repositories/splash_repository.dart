/// Contract for the data the splash screen needs to decide where to navigate.
///
/// Kept in the domain layer so the presentation (cubit) depends on this
/// abstraction, not on storage details. When the auth feature lands it will
/// write the session token that [isAuthenticated] reads.
abstract class SplashRepository {
  /// Returns `true` when a persisted session exists (user is logged in).
  Future<bool> isAuthenticated();
}
