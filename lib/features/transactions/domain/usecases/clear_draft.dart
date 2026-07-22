import '../repositories/transaction_draft_repository.dart';

/// Clears any saved Add Transaction draft (e.g. after a successful save).
class ClearDraft {
  const ClearDraft(this._repository);

  final TransactionDraftRepository _repository;

  Future<void> call() => _repository.clearDraft();
}
