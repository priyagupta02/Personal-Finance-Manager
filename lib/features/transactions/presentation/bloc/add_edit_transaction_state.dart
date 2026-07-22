part of 'add_edit_transaction_cubit.dart';

enum AddEditStatus { editing, submitting, success, failure }

class AddEditTransactionState extends Equatable {
  const AddEditTransactionState({
    this.isEditing = false,
    this.editingId,
    this.hydrated = false,
    this.type = TransactionType.expense,
    this.amountText = '',
    this.category = TransactionCategory.food,
    this.paymentMethod = PaymentMethod.cash,
    required this.date,
    this.description = '',
    this.tags = const [],
    this.isRecurring = false,
    this.receiptPath,
    this.isPickingImage = false,
    this.status = AddEditStatus.editing,
    this.errorMessage,
    this.draftSavedAt,
  });

  final bool isEditing;
  final String? editingId;

  /// Set once the form has been populated from an edited transaction or a
  /// loaded draft, so the UI can seed its text controllers exactly once.
  final bool hydrated;

  final TransactionType type;
  final String amountText;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String description;
  final List<String> tags;
  final bool isRecurring;
  final String? receiptPath;
  final bool isPickingImage;
  final AddEditStatus status;
  final String? errorMessage;

  /// Bumped each time a draft is saved, so the UI can show a confirmation.
  final int? draftSavedAt;

  AddEditTransactionState copyWith({
    bool? isEditing,
    String? editingId,
    bool? hydrated,
    TransactionType? type,
    String? amountText,
    TransactionCategory? category,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? description,
    List<String>? tags,
    bool? isRecurring,
    String? receiptPath,
    bool clearReceipt = false,
    bool? isPickingImage,
    AddEditStatus? status,
    String? errorMessage,
    int? draftSavedAt,
  }) {
    return AddEditTransactionState(
      isEditing: isEditing ?? this.isEditing,
      editingId: editingId ?? this.editingId,
      hydrated: hydrated ?? this.hydrated,
      type: type ?? this.type,
      amountText: amountText ?? this.amountText,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      receiptPath: clearReceipt ? null : (receiptPath ?? this.receiptPath),
      isPickingImage: isPickingImage ?? this.isPickingImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      draftSavedAt: draftSavedAt ?? this.draftSavedAt,
    );
  }

  @override
  List<Object?> get props => [
        isEditing,
        editingId,
        hydrated,
        type,
        amountText,
        category,
        paymentMethod,
        date,
        description,
        tags,
        isRecurring,
        receiptPath,
        isPickingImage,
        status,
        errorMessage,
        draftSavedAt,
      ];
}
