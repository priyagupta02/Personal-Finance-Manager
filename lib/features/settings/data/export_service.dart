import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/domain/usecases/get_transactions.dart';
import '../../budgets/domain/entities/budget.dart';
import '../../budgets/domain/usecases/get_budgets.dart';
import '../../subscriptions/domain/entities/subscription.dart';
import '../../subscriptions/domain/usecases/get_subscriptions.dart';
import '../../../core/usecase/usecase.dart';

/// Gathers all of the user's data into a single JSON document and shares it via
/// the platform share sheet ("Export all data").
class ExportDataService {
  const ExportDataService({
    required GetTransactions getTransactions,
    required GetBudgets getBudgets,
    required GetSubscriptions getSubscriptions,
  })  : _getTransactions = getTransactions,
        _getBudgets = getBudgets,
        _getSubscriptions = getSubscriptions;

  final GetTransactions _getTransactions;
  final GetBudgets _getBudgets;
  final GetSubscriptions _getSubscriptions;

  /// Builds the export document as a pretty-printed JSON string. Pure w.r.t.
  /// the file system, so it can be unit-tested with fake use cases.
  Future<String> buildJson({required String exportedAt}) async {
    final transactions =
        (await _getTransactions(const NoParams())).getOrElse(() => const []);
    final budgets =
        (await _getBudgets(const NoParams())).getOrElse(() => const []);
    final subscriptions =
        (await _getSubscriptions(const NoParams())).getOrElse(() => const []);

    final doc = {
      'exportedAt': exportedAt,
      'transactions': transactions.map(_transactionJson).toList(),
      'budgets': budgets.map(_budgetJson).toList(),
      'subscriptions': subscriptions.map(_subscriptionJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  /// Writes the export to a temp file and opens the share sheet.
  Future<void> exportAndShare({required String exportedAt}) async {
    final json = await buildJson(exportedAt: exportedAt);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finance_export.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Personal Finance Manager — data export',
      ),
    );
  }

  Map<String, dynamic> _transactionJson(Transaction t) => {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'type': t.type.name,
        'category': t.category.name,
        'paymentMethod': t.paymentMethod.name,
        'date': t.date.toIso8601String(),
        'note': t.note,
        'tags': t.tags,
        'isRecurring': t.isRecurring,
      };

  Map<String, dynamic> _budgetJson(Budget b) => {
        'id': b.id,
        'category': b.category.name,
        'limit': b.limit,
        'period': b.period.name,
        'alertThreshold': b.alertThreshold,
        'rollover': b.rollover,
      };

  Map<String, dynamic> _subscriptionJson(Subscription s) => {
        'id': s.id,
        'name': s.name,
        'amount': s.amount,
        'cycle': s.cycle.name,
        'nextBillingDate': s.nextBillingDate.toIso8601String(),
        'autoRenew': s.autoRenew,
      };
}
