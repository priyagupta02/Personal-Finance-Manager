import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/google_auth_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password_cubit.dart';
import '../../features/budgets/data/datasources/budget_local_data_source.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/usecases/delete_budget.dart';
import '../../features/budgets/domain/usecases/get_budgets.dart';
import '../../features/budgets/domain/usecases/save_budget.dart';
import '../../features/budgets/presentation/cubit/budget_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/receipt_scanner/data/datasources/receipt_ocr_service.dart';
import '../../features/receipt_scanner/domain/receipt_parser.dart';
import '../../features/receipt_scanner/presentation/cubit/receipt_scanner_cubit.dart';
import '../../features/settings/data/export_service.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/subscriptions/data/datasources/subscription_local_data_source.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/delete_subscription.dart';
import '../../features/subscriptions/domain/usecases/get_subscriptions.dart';
import '../../features/subscriptions/domain/usecases/save_subscription.dart';
import '../../features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import '../../features/transactions/data/datasources/receipt_image_service.dart';
import '../../features/transactions/data/datasources/transaction_draft_local_data_source.dart';
import '../../features/transactions/data/datasources/transaction_local_data_source.dart';
import '../../features/transactions/data/repositories/transaction_draft_repository_impl.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_draft_repository.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/clear_draft.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/domain/usecases/load_draft.dart';
import '../../features/transactions/domain/usecases/query_transactions.dart';
import '../../features/transactions/domain/usecases/save_draft.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/transactions/presentation/bloc/add_edit_transaction_cubit.dart';
import '../../features/transactions/presentation/bloc/transaction_list_bloc.dart';

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

  // Local database for structured feature data (transactions, budgets).
  await Hive.initFlutter();
  final transactionBox = await Hive.openBox<String>('transactions');
  final budgetBox = await Hive.openBox<String>('budgets');
  final subscriptionBox = await Hive.openBox<String>('subscriptions');

  // --- Feature registrations ---------------------------------------------
  _initAuth();
  _initSplash();
  await _initTransactions(transactionBox);
  await _initBudgets(budgetBox);
  _initHome();
  _initAnalytics();
  _initReceiptScanner();
  await _initSubscriptions(subscriptionBox);
  _initSettings();
}

void _initSettings() {
  sl
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<ExportDataService>(
      () => ExportDataService(
        getTransactions: sl<GetTransactions>(),
        getBudgets: sl<GetBudgets>(),
        getSubscriptions: sl<GetSubscriptions>(),
      ),
    );
}

Future<void> _initSubscriptions(Box<String> box) async {
  final dataSource = SubscriptionLocalDataSource(box);
  await dataSource.seedIfEmpty();
  sl
    ..registerLazySingleton<SubscriptionLocalDataSource>(() => dataSource)
    ..registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl<SubscriptionLocalDataSource>()),
    )
    ..registerLazySingleton(
        () => GetSubscriptions(sl<SubscriptionRepository>()))
    ..registerLazySingleton(
        () => SaveSubscription(sl<SubscriptionRepository>()))
    ..registerLazySingleton(
        () => DeleteSubscription(sl<SubscriptionRepository>()))
    ..registerFactory<SubscriptionsCubit>(
      () => SubscriptionsCubit(
        getSubscriptions: sl<GetSubscriptions>(),
        saveSubscription: sl<SaveSubscription>(),
        deleteSubscription: sl<DeleteSubscription>(),
        now: DateTime.now(),
      ),
    );
}

void _initReceiptScanner() {
  sl
    ..registerLazySingleton<ReceiptOcrService>(() => MlKitReceiptOcrService())
    ..registerLazySingleton(() => const ReceiptParser())
    ..registerFactory<ReceiptScannerCubit>(
      () => ReceiptScannerCubit(
        imageService: sl<ReceiptImageService>(),
        ocrService: sl<ReceiptOcrService>(),
        parser: sl<ReceiptParser>(),
        addTransaction: sl<AddTransaction>(),
        now: DateTime.now(),
      ),
    );
}

void _initAnalytics() {
  sl.registerFactory<AnalyticsCubit>(
    () => AnalyticsCubit(
      getTransactions: sl<GetTransactions>(),
      now: DateTime.now(),
    ),
  );
}

void _initAuth() {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(
        prefs: sl<SharedPreferences>(),
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    )
    ..registerLazySingleton<GoogleAuthService>(
      () => const FirebaseGoogleAuthService(),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl<AuthLocalDataSource>(),
        sl<GoogleAuthService>(),
      ),
    )
    ..registerLazySingleton(() => Login(sl<AuthRepository>()))
    ..registerLazySingleton(() => Register(sl<AuthRepository>()))
    ..registerLazySingleton(() => Logout(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()))
    ..registerLazySingleton(() => SendPasswordReset(sl<AuthRepository>()))
    // AuthBloc holds the app-wide session, so it is a singleton.
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        login: sl<Login>(),
        register: sl<Register>(),
        logout: sl<Logout>(),
        signInWithGoogle: sl<SignInWithGoogle>(),
        repository: sl<AuthRepository>(),
      ),
    )
    ..registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(sl<SendPasswordReset>()),
    );
}

Future<void> _initTransactions(Box<String> box) async {
  final dataSource = TransactionLocalDataSource(box);
  await dataSource.seedIfEmpty();
  sl
    ..registerLazySingleton<TransactionLocalDataSource>(() => dataSource)
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl<TransactionLocalDataSource>()),
    )
    ..registerLazySingleton(() => GetTransactions(sl<TransactionRepository>()))
    ..registerLazySingleton(() => QueryTransactions(sl<TransactionRepository>()))
    ..registerLazySingleton(() => DeleteTransaction(sl<TransactionRepository>()))
    ..registerLazySingleton(() => AddTransaction(sl<TransactionRepository>()))
    ..registerLazySingleton(() => UpdateTransaction(sl<TransactionRepository>()))
    ..registerFactory<TransactionListBloc>(
      () => TransactionListBloc(
        queryTransactions: sl<QueryTransactions>(),
        deleteTransaction: sl<DeleteTransaction>(),
      ),
    )
    // --- Add/Edit form: drafts, image capture, and the cubit --------------
    ..registerLazySingleton<TransactionDraftLocalDataSource>(
      () => TransactionDraftLocalDataSource(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<TransactionDraftRepository>(
      () => TransactionDraftRepositoryImpl(
        sl<TransactionDraftLocalDataSource>(),
      ),
    )
    ..registerLazySingleton(() => SaveDraft(sl<TransactionDraftRepository>()))
    ..registerLazySingleton(() => LoadDraft(sl<TransactionDraftRepository>()))
    ..registerLazySingleton(() => ClearDraft(sl<TransactionDraftRepository>()))
    ..registerLazySingleton<ReceiptImageService>(
      () => ReceiptImageServiceImpl(),
    )
    ..registerFactory<AddEditTransactionCubit>(
      () => AddEditTransactionCubit(
        addTransaction: sl<AddTransaction>(),
        updateTransaction: sl<UpdateTransaction>(),
        saveDraft: sl<SaveDraft>(),
        loadDraft: sl<LoadDraft>(),
        clearDraft: sl<ClearDraft>(),
        imageService: sl<ReceiptImageService>(),
        now: DateTime.now(),
      ),
    );
}

Future<void> _initBudgets(Box<String> box) async {
  final dataSource = BudgetLocalDataSource(box);
  await dataSource.seedIfEmpty();
  sl
    ..registerLazySingleton<BudgetLocalDataSource>(() => dataSource)
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(sl<BudgetLocalDataSource>()),
    )
    ..registerLazySingleton(() => GetBudgets(sl<BudgetRepository>()))
    ..registerLazySingleton(() => SaveBudget(sl<BudgetRepository>()))
    ..registerLazySingleton(() => DeleteBudget(sl<BudgetRepository>()))
    ..registerFactory<BudgetCubit>(
      () => BudgetCubit(
        getBudgets: sl<GetBudgets>(),
        getTransactions: sl<GetTransactions>(),
        saveBudget: sl<SaveBudget>(),
        deleteBudget: sl<DeleteBudget>(),
        now: DateTime.now(),
      ),
    );
}

void _initHome() {
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      getTransactions: sl<GetTransactions>(),
      getBudgets: sl<GetBudgets>(),
    ),
  );
}

void _initSplash() {
  sl
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(sl<FlutterSecureStorage>()),
    )
    // Cubit is per-use (factory) so each splash entry gets a fresh instance.
    ..registerFactory<SplashCubit>(() => SplashCubit(sl<SplashRepository>()));
}
