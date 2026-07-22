import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local, offline authentication backed by device storage.
///
/// Stands in for a real auth API: accounts are stored in [SharedPreferences]
/// with salted SHA-256 password hashes (never plaintext), while the active
/// session token lives in encrypted secure storage. Swapping to a real backend
/// means replacing this class — the repository/domain layers stay untouched.
class AuthLocalDataSource {
  AuthLocalDataSource({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage;

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _usersKey = 'auth_users';
  static const String _currentUserKey = 'auth_current_user';

  // --- Account management -------------------------------------------------

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    final key = email.toLowerCase();
    if (users.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }

    final salt = _generateSalt();
    final record = {
      'id': _generateId(),
      'name': name,
      'email': email,
      'salt': salt,
      'hash': _hash(password, salt),
    };
    users[key] = record;
    await _prefs.setString(_usersKey, jsonEncode(users));

    return _toUser(record);
  }

  Future<UserModel> authenticate({
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    final record = users[email.toLowerCase()];
    if (record == null) {
      throw const AuthException('No account found for this email.');
    }
    final salt = record['salt'] as String;
    if (_hash(password, salt) != record['hash']) {
      throw const AuthException('Incorrect email or password.');
    }
    return _toUser(record);
  }

  // --- Session persistence ------------------------------------------------

  Future<void> cacheSession(UserModel user, String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
    await _secureStorage.write(
      key: _currentUserKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    if (token == null || token.isEmpty) return null;
    final raw = await _secureStorage.read(key: _currentUserKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _secureStorage.delete(key: _currentUserKey);
  }

  // --- Remember me --------------------------------------------------------

  Future<void> setRememberedEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _prefs.remove(StorageKeys.rememberedEmail);
    } else {
      await _prefs.setString(StorageKeys.rememberedEmail, email);
    }
  }

  String? getRememberedEmail() => _prefs.getString(StorageKeys.rememberedEmail);

  // --- Helpers ------------------------------------------------------------

  Map<String, dynamic> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  UserModel _toUser(Map<dynamic, dynamic> record) => UserModel(
        id: record['id'] as String,
        name: record['name'] as String,
        email: record['email'] as String,
      );

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _generateId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(12, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }
}
