import '../../domain/entities/transaction_draft.dart';
import '../../domain/repositories/transaction_draft_repository.dart';
import '../datasources/transaction_draft_local_data_source.dart';
import '../models/transaction_draft_model.dart';

class TransactionDraftRepositoryImpl implements TransactionDraftRepository {
  const TransactionDraftRepositoryImpl(this._local);

  final TransactionDraftLocalDataSource _local;

  @override
  Future<void> saveDraft(TransactionDraft draft) =>
      _local.save(TransactionDraftModel.fromEntity(draft));

  @override
  Future<TransactionDraft?> loadDraft() async => _local.load();

  @override
  Future<void> clearDraft() => _local.clear();
}
