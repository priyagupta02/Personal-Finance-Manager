import '../entities/transaction_draft.dart';
import '../repositories/transaction_draft_repository.dart';

/// Saves the current Add Transaction form as a draft.
class SaveDraft {
  const SaveDraft(this._repository);

  final TransactionDraftRepository _repository;

  Future<void> call(TransactionDraft draft) => _repository.saveDraft(draft);
}
