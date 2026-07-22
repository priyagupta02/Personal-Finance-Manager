import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/config/env_config.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration before anything reads it.
  await EnvConfig.load();

  // Register core dependencies (storage, etc.) in the service locator.
  await configureDependencies();

  // Observe BLoC transitions/errors for easier debugging.
  Bloc.observer = const AppBlocObserver();

  runApp(const FinanceApp());
}
