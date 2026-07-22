import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../domain/entities/budget.dart';
import '../models/budget_model.dart';

/// Persists budgets locally in a Hive box as JSON strings (keyed by id).
class BudgetLocalDataSource {
  BudgetLocalDataSource(this._box);

  final Box<String> _box;

  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    for (final b in _demoBudgets()) {
      await _box.put(b.id, jsonEncode(b.toJson()));
    }
  }

  Future<List<BudgetModel>> getAll() async {
    try {
      return _box.values
          .map((raw) =>
              BudgetModel.fromJson(jsonDecode(raw) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read budgets.');
    }
  }

  Future<void> save(BudgetModel model) async {
    try {
      await _box.put(model.id, jsonEncode(model.toJson()));
    } catch (_) {
      throw const CacheException('Failed to save budget.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const CacheException('Failed to delete budget.');
    }
  }

  List<BudgetModel> _demoBudgets() => const [
        BudgetModel(
          id: 'budget-food',
          category: TransactionCategory.food,
          limit: 6000,
          period: BudgetPeriod.monthly,
        ),
        BudgetModel(
          id: 'budget-groceries',
          category: TransactionCategory.groceries,
          limit: 8000,
          period: BudgetPeriod.monthly,
        ),
        BudgetModel(
          id: 'budget-shopping',
          category: TransactionCategory.shopping,
          limit: 5000,
          period: BudgetPeriod.monthly,
        ),
        BudgetModel(
          id: 'budget-entertainment',
          category: TransactionCategory.entertainment,
          limit: 3000,
          period: BudgetPeriod.monthly,
        ),
      ];
}
