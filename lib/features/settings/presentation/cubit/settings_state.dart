part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = kDefaultCurrency,
    this.biometricEnabled = false,
    this.notifyBudgetAlerts = true,
    this.notifyRenewals = true,
    this.notifyDailySummary = false,
  });

  final ThemeMode themeMode;
  final Currency currency;
  final bool biometricEnabled;
  final bool notifyBudgetAlerts;
  final bool notifyRenewals;
  final bool notifyDailySummary;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Currency? currency,
    bool? biometricEnabled,
    bool? notifyBudgetAlerts,
    bool? notifyRenewals,
    bool? notifyDailySummary,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notifyBudgetAlerts: notifyBudgetAlerts ?? this.notifyBudgetAlerts,
      notifyRenewals: notifyRenewals ?? this.notifyRenewals,
      notifyDailySummary: notifyDailySummary ?? this.notifyDailySummary,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        currency,
        biometricEnabled,
        notifyBudgetAlerts,
        notifyRenewals,
        notifyDailySummary,
      ];
}
