import '../entities/transaction_draft.dart';
import '../repositories/transaction_draft_repository.dart';

/// Loads the saved Add Transaction draft, if any.
class LoadDraft {
  const LoadDraft(this._repository);

  final TransactionDraftRepository _repository;

  Future<TransactionDraft?> call() => _repository.loadDraft();
}
