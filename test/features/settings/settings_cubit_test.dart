import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/utils/currency_formatter.dart';
import 'package:personal_finance_manager/features/settings/domain/currency.dart';
import 'package:personal_finance_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    CurrencyFormatter.setCurrency('₹');
  });

  test('load applies sensible defaults', () {
    final cubit = SettingsCubit(prefs)..load();
    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.currency.code, 'INR');
    expect(cubit.state.notifyBudgetAlerts, isTrue);
  });

  test('setThemeMode persists and emits', () async {
    final cubit = SettingsCubit(prefs)..load();
    await cubit.setThemeMode(ThemeMode.dark);
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('setCurrency updates the formatter and persists the code', () async {
    final cubit = SettingsCubit(prefs)..load();
    final usd = kSupportedCurrencies.firstWhere((c) => c.code == 'USD');
    await cubit.setCurrency(usd);

    expect(cubit.state.currency.code, 'USD');
    expect(CurrencyFormatter.activeSymbol, r'$');
    expect(prefs.getString('currency_code'), 'USD');
  });

  test('notification toggles persist', () async {
    final cubit = SettingsCubit(prefs)..load();
    await cubit.setNotifyDailySummary(true);
    expect(cubit.state.notifyDailySummary, isTrue);
    expect(prefs.getBool('notify_daily_summary'), isTrue);
  });
}
