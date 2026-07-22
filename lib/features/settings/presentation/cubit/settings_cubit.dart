import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/currency.dart';

part 'settings_state.dart';

/// Holds app-wide user preferences (theme, currency, notifications, biometric)
/// and persists them to SharedPreferences. Provided above the router so the
/// theme and currency take effect immediately.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs) : super(const SettingsState());

  final SharedPreferences _prefs;

  void load() {
    final currency =
        currencyForCode(_prefs.getString(StorageKeys.currencyCode) ?? 'INR');
    CurrencyFormatter.setCurrency(currency.symbol);

    emit(SettingsState(
      themeMode: _themeFromString(_prefs.getString(StorageKeys.themeMode)),
      currency: currency,
      biometricEnabled: _prefs.getBool(StorageKeys.biometricEnabled) ?? false,
      notifyBudgetAlerts:
          _prefs.getBool(StorageKeys.notifyBudgetAlerts) ?? true,
      notifyRenewals: _prefs.getBool(StorageKeys.notifyRenewals) ?? true,
      notifyDailySummary:
          _prefs.getBool(StorageKeys.notifyDailySummary) ?? false,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setCurrency(Currency currency) async {
    await _prefs.setString(StorageKeys.currencyCode, currency.code);
    CurrencyFormatter.setCurrency(currency.symbol);
    emit(state.copyWith(currency: currency));
  }

  Future<void> setBiometric(bool enabled) async {
    await _prefs.setBool(StorageKeys.biometricEnabled, enabled);
    emit(state.copyWith(biometricEnabled: enabled));
  }

  Future<void> setNotifyBudgetAlerts(bool v) async {
    await _prefs.setBool(StorageKeys.notifyBudgetAlerts, v);
    emit(state.copyWith(notifyBudgetAlerts: v));
  }

  Future<void> setNotifyRenewals(bool v) async {
    await _prefs.setBool(StorageKeys.notifyRenewals, v);
    emit(state.copyWith(notifyRenewals: v));
  }

  Future<void> setNotifyDailySummary(bool v) async {
    await _prefs.setBool(StorageKeys.notifyDailySummary, v);
    emit(state.copyWith(notifyDailySummary: v));
  }

  ThemeMode _themeFromString(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
