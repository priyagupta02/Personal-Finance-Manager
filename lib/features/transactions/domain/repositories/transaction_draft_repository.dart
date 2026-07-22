import '../entities/transaction_draft.dart';

/// Persists a single in-progress Add Transaction draft.
abstract class TransactionDraftRepository {
  Future<void> saveDraft(TransactionDraft draft);

  Future<TransactionDraft?> loadDraft();

  Future<void> clearDraft();
}
