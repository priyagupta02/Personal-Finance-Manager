import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../transactions/data/datasources/receipt_image_service.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../cubit/receipt_scanner_cubit.dart';

class ReceiptScannerPage extends StatelessWidget {
  const ReceiptScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptScannerCubit>(),
      child: const _ReceiptScannerView(),
    );
  }
}

class _ReceiptScannerView extends StatefulWidget {
  const _ReceiptScannerView();

  @override
  State<_ReceiptScannerView> createState() => _ReceiptScannerViewState();
}

class _ReceiptScannerViewState extends State<_ReceiptScannerView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null && mounted) {
      context.read<ReceiptScannerCubit>().dateChanged(date);
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ReceiptScannerCubit>().save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: BlocConsumer<ReceiptScannerCubit, ReceiptScannerState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == ScanStatus.review && !_seeded) {
            _amountController.text = state.amountText;
            _descriptionController.text = state.description;
            _seeded = true;
          }
          if (state.status == ScanStatus.saved) {
            context.pop(true);
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            ScanStatus.idle => _CaptureView(
                onPick: (s) => context.read<ReceiptScannerCubit>().capture(s),
              ),
            ScanStatus.processing => const _Busy(label: 'Reading receipt…'),
            ScanStatus.saving => const _Busy(label: 'Saving…'),
            ScanStatus.error => _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () {
                  _seeded = false;
                  context.read<ReceiptScannerCubit>().reset();
                },
              ),
            ScanStatus.review || ScanStatus.saved => _ReviewForm(
                formKey: _formKey,
                amountController: _amountController,
                descriptionController: _descriptionController,
                state: state,
                onAmountChanged:
                    context.read<ReceiptScannerCubit>().amountChanged,
                onDescriptionChanged:
                    context.read<ReceiptScannerCubit>().descriptionChanged,
                onCategoryChanged:
                    context.read<ReceiptScannerCubit>().categoryChanged,
                onPickDate: () => _pickDate(state.date),
                onSave: _save,
                onRetake: () {
                  _seeded = false;
                  context.read<ReceiptScannerCubit>().reset();
                },
              ),
          };
        },
      ),
    );
  }
}

class _CaptureView extends StatelessWidget {
  const _CaptureView({required this.onPick});

  final ValueChanged<ReceiptSource> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_outlined,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Scan a receipt',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'We\'ll read the amount, date and merchant for you.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onPick(ReceiptSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Use camera'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onPick(ReceiptSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.formKey,
    required this.amountController,
    required this.descriptionController,
    required this.state,
    required this.onAmountChanged,
    required this.onDescriptionChanged,
    required this.onCategoryChanged,
    required this.onPickDate,
    required this.onSave,
    required this.onRetake,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final ReceiptScannerState state;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<TransactionCategory> onCategoryChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSave;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(state.imagePath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 180,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Review the details we extracted, then save.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            onChanged: onAmountChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: Validators.amount,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '${CurrencyFormatter.defaultSymbol} ',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.event),
              ),
              child: Text(DateFormat('EEE, d MMM yyyy').format(state.date)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            onChanged: onDescriptionChanged,
            decoration: const InputDecoration(
              labelText: 'Merchant / Description',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransactionCategory>(
            initialValue: state.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in TransactionCategory.values)
                DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 20, color: c.color),
                      const SizedBox(width: 12),
                      Text(c.label),
                    ],
                  ),
                ),
            ],
            onChanged: (c) => c != null ? onCategoryChanged(c) : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.status == ScanStatus.saving ? null : onSave,
            child: const Text('Save transaction'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetake,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan another'),
          ),
        ],
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
