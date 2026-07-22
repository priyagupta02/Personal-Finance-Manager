import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/splash_repository.dart';

/// Determines auth state by checking for a persisted session token in secure
/// storage. The auth feature writes [StorageKeys.authToken] on login; here we
/// only read it, keeping the two features decoupled via the shared key.
class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }
}
