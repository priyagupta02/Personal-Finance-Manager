import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/usecase/usecase.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budgets/domain/usecases/get_budgets.dart';
import '../../subscriptions/domain/usecases/get_subscriptions.dart';
import '../../transactions/domain/entities/transaction_enums.dart';
import '../../transactions/domain/usecases/get_transactions.dart';
import 'local_notification_service.dart';

/// Turns app data + the user's notification preferences into scheduled local
/// notifications: subscription renewal reminders (3 days before), a daily
/// summary, and budget-threshold alerts. Re-run on startup and whenever the
/// preferences change.
class NotificationScheduler {
  NotificationScheduler({
    required LocalNotificationService local,
    required SharedPreferences prefs,
    required GetSubscriptions getSubscriptions,
    required GetBudgets getBudgets,
    required GetTransactions getTransactions,
    DateTime Function() now = DateTime.now,
  })  : _local = local,
        _prefs = prefs,
        _getSubscriptions = getSubscriptions,
        _getBudgets = getBudgets,
        _getTransactions = getTransactions,
        _now = now;

  final LocalNotificationService _local;
  final SharedPreferences _prefs;
  final GetSubscriptions _getSubscriptions;
  final GetBudgets _getBudgets;
  final GetTransactions _getTransactions;
  final DateTime Function() _now;

  static const int _dailyId = 1;
  static const int _renewalBase = 1000;
  static const int _budgetBase = 2000;

  Future<void> sync() async {
    // Rebuild from scratch so toggling a preference off cancels its reminders.
    await _local.cancelAll();

    await _scheduleRenewals();
    _scheduleDailySummary();
    await _showBudgetAlerts();
  }

  Future<void> _scheduleRenewals() async {
    if (!(_prefs.getBool(StorageKeys.notifyRenewals) ?? true)) return;
    final subs = (await _getSubscriptions(const NoParams()))
        .getOrElse(() => const []);
    for (var i = 0; i < subs.length; i++) {
      final s = subs[i];
      final remindAt = s.nextBillingDate.subtract(const Duration(days: 3));
      await _local.scheduleAt(
        _renewalBase + i,
        '${s.name} renews soon',
        '${CurrencyFormatter.format(s.amount)} on '
            '${DateFormat('d MMM').format(s.nextBillingDate)}',
        remindAt,
      );
    }
  }

  void _scheduleDailySummary() {
    if (!(_prefs.getBool(StorageKeys.notifyDailySummary) ?? false)) return;
    _local.scheduleDaily(
      _dailyId,
      'Daily spending summary',
      'Open Personal Finance Manager to review today\'s spending.',
    );
  }

  Future<void> _showBudgetAlerts() async {
    if (!(_prefs.getBool(StorageKeys.notifyBudgetAlerts) ?? true)) return;

    final budgets =
        (await _getBudgets(const NoParams())).getOrElse(() => const []);
    final txs =
        (await _getTransactions(const NoParams())).getOrElse(() => const []);
    final now = _now();

    for (final b in budgets) {
      final spent = txs
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category == b.category &&
              t.date.year == now.year &&
              t.date.month == now.month)
          .fold<double>(0, (sum, t) => sum + t.amount);

      if (b.limit > 0 && (spent / b.limit) * 100 >= b.alertThreshold) {
        await _local.show(
          _budgetBase + b.category.index,
          '${b.category.label} budget at ${b.alertThreshold}%',
          'Spent ${CurrencyFormatter.format(spent)} of '
              '${CurrencyFormatter.format(b.limit)}',
        );
      }
    }
  }
}
