import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/config/env_config.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration before anything reads it.
  await EnvConfig.load();

  // Initialize Firebase + Google Sign-In. Guarded so the app still runs before
  // `flutterfire configure` has been run (Google sign-in simply stays disabled).
  await _initFirebase();

  // Register core dependencies (storage, etc.) in the service locator.
  await configureDependencies();

  // Observe BLoC transitions/errors for easier debugging.
  Bloc.observer = const AppBlocObserver();

  runApp(const FinanceApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final clientId = EnvConfig.googleWebClientId;
    await GoogleSignIn.instance.initialize(
      serverClientId: clientId.isEmpty ? null : clientId,
    );
  } catch (error, stackTrace) {
    developer.log(
      'Firebase not configured — Google sign-in disabled. '
      'Run `flutterfire configure` to enable it.',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
