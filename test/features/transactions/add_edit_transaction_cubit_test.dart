import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/transactions/data/datasources/receipt_image_service.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_draft.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_page.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_draft_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/add_transaction.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/clear_draft.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/load_draft.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/save_draft.dart';
import 'package:personal_finance_manager/features/transactions/domain/usecases/update_transaction.dart';
import 'package:personal_finance_manager/features/transactions/presentation/bloc/add_edit_transaction_cubit.dart';

class _FakeTxRepo implements TransactionRepository {
  final List<Transaction> added = [];
  final List<Transaction> updated = [];

  @override
  Future<Either<Failure, Unit>> addTransaction(Transaction t) async {
    added.add(t);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(Transaction t) async {
    updated.add(t);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async =>
      const Right(unit);
  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async =>
      const Right([]);
  @override
  Future<Either<Failure, TransactionPage>> queryTransactions(
          TransactionFilter f) async =>
      const Right(TransactionPage(items: [], hasMore: false, totalCount: 0));
}

class _FakeDraftRepo implements TransactionDraftRepository {
  TransactionDraft? draft;
  bool cleared = false;

  @override
  Future<void> saveDraft(TransactionDraft d) async => draft = d;
  @override
  Future<TransactionDraft?> loadDraft() async => draft;
  @override
  Future<void> clearDraft() async {
    cleared = true;
    draft = null;
  }
}

class _FakeImageService implements ReceiptImageService {
  @override
  Future<String?> pickAndCompress(ReceiptSource source) async =>
      '/tmp/receipt.jpg';
}

void main() {
  late _FakeTxRepo txRepo;
  late _FakeDraftRepo draftRepo;

  AddEditTransactionCubit build() => AddEditTransactionCubit(
        addTransaction: AddTransaction(txRepo),
        updateTransaction: UpdateTransaction(txRepo),
        saveDraft: SaveDraft(draftRepo),
        loadDraft: LoadDraft(draftRepo),
        clearDraft: ClearDraft(draftRepo),
        imageService: _FakeImageService(),
        now: DateTime(2026, 1, 1),
      );

  setUp(() {
    txRepo = _FakeTxRepo();
    draftRepo = _FakeDraftRepo();
  });

  test('init without a draft hydrates with defaults', () async {
    final cubit = build();
    await cubit.init(null);
    expect(cubit.state.hydrated, isTrue);
    expect(cubit.state.isEditing, isFalse);
    await cubit.close();
  });

  test('init with a transaction enters edit mode and prefills', () async {
    final cubit = build();
    await cubit.init(Transaction(
      id: 't1',
      title: 'Coffee',
      amount: 250,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      paymentMethod: PaymentMethod.card,
      date: DateTime(2026, 1, 5),
      note: 'Coffee',
    ));
    expect(cubit.state.isEditing, isTrue);
    expect(cubit.state.editingId, 't1');
    expect(cubit.state.amountText, '250');
    expect(cubit.state.category, TransactionCategory.food);
    await cubit.close();
  });

  test('submit adds a transaction and clears the draft', () async {
    final cubit = build();
    await cubit.init(null);
    cubit
      ..typeChanged(TransactionType.expense)
      ..amountChanged('1200')
      ..categoryChanged(TransactionCategory.shopping)
      ..descriptionChanged('New shoes');

    await cubit.submit();

    expect(cubit.state.status, AddEditStatus.success);
    expect(txRepo.added.single.amount, 1200);
    expect(txRepo.added.single.title, 'New shoes');
    expect(txRepo.added.single.category, TransactionCategory.shopping);
    expect(draftRepo.cleared, isTrue);
    await cubit.close();
  });

  test('submit with an invalid amount fails', () async {
    final cubit = build();
    await cubit.init(null);
    cubit.amountChanged('');
    await cubit.submit();
    expect(cubit.state.status, AddEditStatus.failure);
    expect(txRepo.added, isEmpty);
    await cubit.close();
  });

  test('saveDraft persists the current form', () async {
    final cubit = build();
    await cubit.init(null);
    cubit.amountChanged('99');
    await cubit.saveDraft();
    expect(draftRepo.draft?.amountText, '99');
    expect(cubit.state.draftSavedAt, 1);
    await cubit.close();
  });

  test('pickReceipt attaches a compressed image path', () async {
    final cubit = build();
    await cubit.init(null);
    await cubit.pickReceipt(ReceiptSource.gallery);
    expect(cubit.state.receiptPath, '/tmp/receipt.jpg');
    expect(cubit.state.isPickingImage, isFalse);
    await cubit.close();
  });
}
