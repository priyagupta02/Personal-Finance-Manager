import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Signs the user in with Google via Firebase Auth. Isolated behind this
/// interface so the (fast-moving) google_sign_in / firebase_auth APIs stay out
/// of the repository, and so it can be stubbed in tests.
abstract class GoogleAuthService {
  Future<UserModel> signIn();
  Future<void> signOut();
}

class FirebaseGoogleAuthService implements GoogleAuthService {
  const FirebaseGoogleAuthService();

  @override
  Future<UserModel> signIn() async {
    try {
      // google_sign_in v7: initialize() must have run once (done in bootstrap).
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google sign-in failed: missing token.');
      }

      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final result =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const AuthException('Google sign-in failed.');
      }

      return UserModel(
        id: user.uid,
        name: user.displayName ?? googleUser.displayName ?? 'User',
        email: user.email ?? googleUser.email,
        avatarUrl: user.photoURL,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      throw AuthException('Google sign-in failed (${e.code.name}).');
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign-in failed.');
    }
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await fb.FirebaseAuth.instance.signOut();
  }
}
