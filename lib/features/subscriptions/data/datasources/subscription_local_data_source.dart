import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription.dart';
import '../models/subscription_model.dart';

/// Persists subscriptions locally in a Hive box as JSON strings (keyed by id).
class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this._box);

  final Box<String> _box;

  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    for (final s in _demo()) {
      await _box.put(s.id, jsonEncode(s.toJson()));
    }
  }

  Future<List<SubscriptionModel>> getAll() async {
    try {
      return _box.values
          .map((raw) => SubscriptionModel.fromJson(
              jsonDecode(raw) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read subscriptions.');
    }
  }

  Future<void> save(SubscriptionModel model) async {
    try {
      await _box.put(model.id, jsonEncode(model.toJson()));
    } catch (_) {
      throw const CacheException('Failed to save subscription.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const CacheException('Failed to delete subscription.');
    }
  }

  List<SubscriptionModel> _demo() {
    final now = DateTime.now();
    DateTime inDays(int d) => DateTime(now.year, now.month, now.day + d);
    return [
      SubscriptionModel(
        id: 'sub-netflix',
        name: 'Netflix',
        amount: 649,
        cycle: BillingCycle.monthly,
        nextBillingDate: inDays(2),
      ),
      SubscriptionModel(
        id: 'sub-spotify',
        name: 'Spotify',
        amount: 119,
        cycle: BillingCycle.monthly,
        nextBillingDate: inDays(9),
      ),
      SubscriptionModel(
        id: 'sub-icloud',
        name: 'iCloud+',
        amount: 75,
        cycle: BillingCycle.monthly,
        nextBillingDate: inDays(16),
      ),
      SubscriptionModel(
        id: 'sub-prime',
        name: 'Amazon Prime',
        amount: 1499,
        cycle: BillingCycle.yearly,
        nextBillingDate: inDays(40),
      ),
      SubscriptionModel(
        id: 'sub-gym',
        name: 'Gym Membership',
        amount: 1200,
        cycle: BillingCycle.monthly,
        nextBillingDate: inDays(5),
        autoRenew: false,
      ),
    ];
  }
}
