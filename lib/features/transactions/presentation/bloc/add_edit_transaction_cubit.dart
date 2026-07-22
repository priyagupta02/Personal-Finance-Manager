import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/id_generator.dart';
import '../../data/datasources/receipt_image_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_draft.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/clear_draft.dart';
import '../../domain/usecases/load_draft.dart';
import '../../domain/usecases/save_draft.dart';
import '../../domain/usecases/update_transaction.dart';

part 'add_edit_transaction_state.dart';

/// Drives the Add/Edit Transaction form: field changes, receipt capture,
/// draft save/restore, and submission.
class AddEditTransactionCubit extends Cubit<AddEditTransactionState> {
  AddEditTransactionCubit({
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required SaveDraft saveDraft,
    required LoadDraft loadDraft,
    required ClearDraft clearDraft,
    required ReceiptImageService imageService,
    required DateTime now,
  })  : _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _saveDraft = saveDraft,
        _loadDraft = loadDraft,
        _clearDraft = clearDraft,
        _imageService = imageService,
        super(AddEditTransactionState(date: now));

  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final SaveDraft _saveDraft;
  final LoadDraft _loadDraft;
  final ClearDraft _clearDraft;
  final ReceiptImageService _imageService;

  /// Populates the form from an existing [transaction] (edit) or a saved draft
  /// (add). Call once when the page opens.
  Future<void> init(Transaction? transaction) async {
    if (transaction != null) {
      emit(state.copyWith(
        isEditing: true,
        editingId: transaction.id,
        hydrated: true,
        type: transaction.type,
        amountText: _formatAmount(transaction.amount),
        category: transaction.category,
        paymentMethod: transaction.paymentMethod,
        date: transaction.date,
        description: transaction.note ?? transaction.title,
        tags: transaction.tags,
        isRecurring: transaction.isRecurring,
        receiptPath: transaction.receiptPath,
      ));
      return;
    }

    final draft = await _loadDraft();
    if (draft != null) {
      emit(state.copyWith(
        hydrated: true,
        type: draft.type,
        amountText: draft.amountText,
        category: draft.category,
        paymentMethod: draft.paymentMethod,
        date: draft.date,
        description: draft.description,
        tags: draft.tags,
        isRecurring: draft.isRecurring,
        receiptPath: draft.receiptPath,
      ));
    } else {
      emit(state.copyWith(hydrated: true));
    }
  }

  void typeChanged(TransactionType type) => emit(state.copyWith(type: type));
  void amountChanged(String value) => emit(state.copyWith(amountText: value));
  void categoryChanged(TransactionCategory c) =>
      emit(state.copyWith(category: c));
  void paymentMethodChanged(PaymentMethod m) =>
      emit(state.copyWith(paymentMethod: m));
  void dateChanged(DateTime date) => emit(state.copyWith(date: date));
  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));
  void recurringChanged(bool value) =>
      emit(state.copyWith(isRecurring: value));
  void removeReceipt() => emit(state.copyWith(clearReceipt: true));

  void toggleTag(String tag) {
    final tags = [...state.tags];
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    emit(state.copyWith(tags: tags));
  }

  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || state.tags.contains(trimmed)) return;
    emit(state.copyWith(tags: [...state.tags, trimmed]));
  }

  Future<void> pickReceipt(ReceiptSource source) async {
    emit(state.copyWith(isPickingImage: true));
    try {
      final path = await _imageService.pickAndCompress(source);
      emit(state.copyWith(
        isPickingImage: false,
        receiptPath: path ?? state.receiptPath,
      ));
    } catch (_) {
      emit(state.copyWith(
        isPickingImage: false,
        errorMessage: 'Could not attach the image.',
      ));
    }
  }

  Future<void> saveDraft() async {
    await _saveDraft(_toDraft());
    emit(state.copyWith(draftSavedAt: (state.draftSavedAt ?? 0) + 1));
  }

  /// Persists the transaction. Assumes the form has already validated the
  /// amount. Returns nothing; the UI reacts to [AddEditStatus].
  Future<void> submit() async {
    final amount = double.tryParse(state.amountText.trim());
    if (amount == null || amount <= 0) {
      emit(state.copyWith(
        status: AddEditStatus.failure,
        errorMessage: 'Enter a valid amount.',
      ));
      return;
    }

    emit(state.copyWith(status: AddEditStatus.submitting));

    final description = state.description.trim();
    final transaction = Transaction(
      id: state.editingId ?? IdGenerator.generate(),
      title: description.isNotEmpty ? description : state.category.label,
      amount: amount,
      type: state.type,
      category: state.category,
      paymentMethod: state.paymentMethod,
      date: state.date,
      note: description.isEmpty ? null : description,
      tags: state.tags,
      isRecurring: state.isRecurring,
      receiptPath: state.receiptPath,
    );

    final result = state.isEditing
        ? await _updateTransaction(transaction)
        : await _addTransaction(transaction);

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: AddEditStatus.failure,
        errorMessage: failure.message,
      )),
      (_) async {
        if (!state.isEditing) await _clearDraft();
        emit(state.copyWith(status: AddEditStatus.success));
      },
    );
  }

  TransactionDraft _toDraft() => TransactionDraft(
        type: state.type,
        amountText: state.amountText,
        category: state.category,
        paymentMethod: state.paymentMethod,
        date: state.date,
        description: state.description,
        tags: state.tags,
        isRecurring: state.isRecurring,
        receiptPath: state.receiptPath,
      );

  String _formatAmount(double amount) =>
      amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : '$amount';
}
