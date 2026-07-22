import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_draft_model.dart';

/// Stores the single Add Transaction draft as JSON in SharedPreferences.
class TransactionDraftLocalDataSource {
  TransactionDraftLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'transaction_draft';

  Future<void> save(TransactionDraftModel draft) =>
      _prefs.setString(_key, jsonEncode(draft.toJson()));

  TransactionDraftModel? load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    return TransactionDraftModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clear() => _prefs.remove(_key);
}
