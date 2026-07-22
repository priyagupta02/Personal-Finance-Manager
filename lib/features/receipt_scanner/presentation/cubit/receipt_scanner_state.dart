part of 'receipt_scanner_cubit.dart';

enum ScanStatus { idle, processing, review, saving, saved, error }

class ReceiptScannerState extends Equatable {
  const ReceiptScannerState({
    this.status = ScanStatus.idle,
    this.imagePath,
    this.rawText = '',
    this.amountText = '',
    required this.date,
    this.description = '',
    this.category = TransactionCategory.other,
    this.errorMessage,
  });

  final ScanStatus status;
  final String? imagePath;
  final String rawText;

  // Editable review fields, pre-filled from OCR.
  final String amountText;
  final DateTime date;
  final String description;
  final TransactionCategory category;

  final String? errorMessage;

  ReceiptScannerState copyWith({
    ScanStatus? status,
    String? imagePath,
    String? rawText,
    String? amountText,
    DateTime? date,
    String? description,
    TransactionCategory? category,
    String? errorMessage,
  }) {
    return ReceiptScannerState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      rawText: rawText ?? this.rawText,
      amountText: amountText ?? this.amountText,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        imagePath,
        rawText,
        amountText,
        date,
        description,
        category,
        errorMessage,
      ];
}
