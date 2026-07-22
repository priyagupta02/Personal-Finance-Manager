import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/id_generator.dart';
import '../../../transactions/data/datasources/receipt_image_service.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../../data/datasources/receipt_ocr_service.dart';
import '../../domain/receipt_parser.dart';

part 'receipt_scanner_state.dart';

/// Drives the receipt flow: capture -> OCR -> parse -> review -> save.
class ReceiptScannerCubit extends Cubit<ReceiptScannerState> {
  ReceiptScannerCubit({
    required ReceiptImageService imageService,
    required ReceiptOcrService ocrService,
    required ReceiptParser parser,
    required AddTransaction addTransaction,
    required DateTime now,
  })  : _imageService = imageService,
        _ocrService = ocrService,
        _parser = parser,
        _addTransaction = addTransaction,
        super(ReceiptScannerState(date: now));

  final ReceiptImageService _imageService;
  final ReceiptOcrService _ocrService;
  final ReceiptParser _parser;
  final AddTransaction _addTransaction;

  Future<void> capture(ReceiptSource source) async {
    emit(state.copyWith(status: ScanStatus.processing));
    try {
      final path = await _imageService.pickAndCompress(source);
      if (path == null) {
        emit(state.copyWith(status: ScanStatus.idle));
        return;
      }
      final text = await _ocrService.recognizeText(path);
      final receipt = _parser.parse(text);

      emit(state.copyWith(
        status: ScanStatus.review,
        imagePath: path,
        rawText: text,
        amountText: receipt.amount != null
            ? receipt.amount!.toStringAsFixed(2)
            : '',
        date: receipt.date ?? state.date,
        description: receipt.merchant ?? '',
        category: receipt.categorySuggestion ?? TransactionCategory.other,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Could not read the receipt. Try again or enter manually.',
      ));
    }
  }

  void amountChanged(String v) => emit(state.copyWith(amountText: v));
  void dateChanged(DateTime d) => emit(state.copyWith(date: d));
  void descriptionChanged(String v) => emit(state.copyWith(description: v));
  void categoryChanged(TransactionCategory c) =>
      emit(state.copyWith(category: c));

  void reset() => emit(ReceiptScannerState(date: state.date));

  Future<void> save() async {
    final amount = double.tryParse(state.amountText.trim());
    if (amount == null || amount <= 0) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Enter a valid amount.',
      ));
      return;
    }
    emit(state.copyWith(status: ScanStatus.saving));

    final description = state.description.trim();
    final transaction = Transaction(
      id: IdGenerator.generate(),
      title: description.isNotEmpty ? description : state.category.label,
      amount: amount,
      type: TransactionType.expense,
      category: state.category,
      paymentMethod: PaymentMethod.card,
      date: state.date,
      note: description.isEmpty ? null : description,
      receiptPath: state.imagePath,
    );

    final result = await _addTransaction(transaction);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ScanStatus.saved)),
    );
  }
}
