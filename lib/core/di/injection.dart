import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator.
///
/// Feature modules register their own data sources, repositories, use cases,
/// and BLoCs here via dedicated `init...()` helpers, keeping wiring explicit
/// and testable (tests can register fakes against the same locator).
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // --- External / core singletons ---------------------------------------
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // --- Feature registrations ---------------------------------------------
  // Registered here as features are implemented, e.g.:
  //   _initAuth();
  //   _initTransactions();
}
