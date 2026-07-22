import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';
import 'demo_transactions.dart';

/// Persists transactions locally in a Hive box as JSON strings (keyed by id).
///
/// Using JSON avoids generated Hive adapters while keeping the door open for a
/// real backend: swap this class and the repository is unaffected.
class TransactionLocalDataSource {
  TransactionLocalDataSource(this._box);

  final Box<String> _box;

  /// On first launch the box is empty, so seed demo data to make the dashboard
  /// meaningful before the user has added anything.
  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    for (final t in buildDemoTransactions()) {
      await _box.put(t.id, jsonEncode(t.toJson()));
    }
  }

  Future<List<TransactionModel>> getAll() async {
    try {
      final items = _box.values
          .map((raw) =>
              TransactionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return items;
    } catch (_) {
      throw const CacheException('Failed to read transactions.');
    }
  }

  Future<void> save(TransactionModel model) async {
    try {
      await _box.put(model.id, jsonEncode(model.toJson()));
    } catch (_) {
      throw const CacheException('Failed to save transaction.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const CacheException('Failed to delete transaction.');
    }
  }
}
