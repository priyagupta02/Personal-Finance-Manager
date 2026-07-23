// PLACEHOLDER — real values are generated locally by `flutterfire configure`
// and are intentionally NOT committed (they carry project-specific client
// config). Firebase initialization is guarded in `main()`, so the app builds
// and runs with these placeholders; Google Sign-In / FCM activate once you run:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// See README → "Firebase Setup".
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _placeholder;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return _placeholder;
      default:
        return _placeholder;
    }
  }

  static const FirebaseOptions _placeholder = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'replace-me',
  );
}
