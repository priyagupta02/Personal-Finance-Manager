import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../data/datasources/receipt_image_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../bloc/add_edit_transaction_cubit.dart';

/// Predefined tag suggestions; users can also add their own.
const _suggestedTags = ['Work', 'Personal', 'Essential', 'Subscription', 'Tax'];

class AddEditTransactionPage extends StatelessWidget {
  const AddEditTransactionPage({this.transaction, super.key});

  final Transaction? transaction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddEditTransactionCubit>()..init(transaction),
      child: const _AddEditView(),
    );
  }
}

class _AddEditView extends StatefulWidget {
  const _AddEditView();

  @override
  State<_AddEditView> createState() => _AddEditViewState();
}

class _AddEditViewState extends State<_AddEditView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AddEditTransactionCubit>().submit();
  }

  Future<void> _pickDateTime(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? current.hour,
      time?.minute ?? current.minute,
    );
    context.read<AddEditTransactionCubit>().dateChanged(combined);
  }

  Future<void> _chooseImageSource() async {
    final source = await showModalBottomSheet<ReceiptSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ReceiptSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ReceiptSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) {
      await context.read<AddEditTransactionCubit>().pickReceipt(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddEditTransactionCubit, AddEditTransactionState>(
      listenWhen: (p, c) =>
          (!p.hydrated && c.hydrated) ||
          p.status != c.status ||
          p.draftSavedAt != c.draftSavedAt,
      listener: (context, state) {
        if (!state.hydrated) return;
        // Seed controllers exactly once after hydration.
        if (_amountController.text != state.amountText &&
            _amountController.text.isEmpty) {
          _amountController.text = state.amountText;
          _descriptionController.text = state.description;
        }
        if (state.status == AddEditStatus.success) {
          context.pop(true);
        } else if (state.status == AddEditStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.draftSavedAt != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Draft saved')));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddEditTransactionCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isEditing ? 'Edit Transaction' : 'Add Transaction',
            ),
            actions: [
              if (!state.isEditing)
                TextButton(
                  onPressed: cubit.saveDraft,
                  child: const Text('Save draft'),
                ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TypeSelector(
                    type: state.type,
                    onChanged: cubit.typeChanged,
                  ),
                  const SizedBox(height: 16),
                  _AmountField(controller: _amountController, onChanged: cubit.amountChanged),
                  const SizedBox(height: 16),
                  _CategoryDropdown(
                    value: state.category,
                    onChanged: cubit.categoryChanged,
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    date: state.date,
                    onTap: () => _pickDateTime(state.date),
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodDropdown(
                    value: state.paymentMethod,
                    onChanged: cubit.paymentMethodChanged,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    onChanged: cubit.descriptionChanged,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ReceiptField(
                    receiptPath: state.receiptPath,
                    isPicking: state.isPickingImage,
                    onAttach: _chooseImageSource,
                    onRemove: cubit.removeReceipt,
                  ),
                  const SizedBox(height: 16),
                  _TagsField(
                    tags: state.tags,
                    controller: _tagController,
                    onToggle: cubit.toggleTag,
                    onAdd: (t) {
                      cubit.addTag(t);
                      _tagController.clear();
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recurring transaction'),
                    value: state.isRecurring,
                    onChanged: cubit.recurringChanged,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        state.status == AddEditStatus.submitting ? null : _submit,
                    child: state.status == AddEditStatus.submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(state.isEditing ? 'Save Changes' : 'Add Transaction'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: [
        for (final t in TransactionType.values)
          ButtonSegment(value: t, label: Text(t.label)),
      ],
      selected: {type},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      validator: Validators.amount,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '${CurrencyFormatter.activeSymbol} ',
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.value, required this.onChanged});

  final TransactionCategory value;
  final ValueChanged<TransactionCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TransactionCategory>(
      initialValue: value,
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
      onChanged: (c) => c != null ? onChanged(c) : null,
    );
  }
}

class _PaymentMethodDropdown extends StatelessWidget {
  const _PaymentMethodDropdown({required this.value, required this.onChanged});

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PaymentMethod>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Payment method'),
      items: [
        for (final m in PaymentMethod.values)
          DropdownMenuItem(
            value: m,
            child: Row(
              children: [
                Icon(m.icon, size: 20),
                const SizedBox(width: 12),
                Text(m.label),
              ],
            ),
          ),
      ],
      onChanged: (m) => m != null ? onChanged(m) : null,
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date & time',
          prefixIcon: Icon(Icons.event),
        ),
        child: Text(DateFormat('EEE, d MMM yyyy · h:mm a').format(date)),
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({
    required this.receiptPath,
    required this.isPicking,
    required this.onAttach,
    required this.onRemove,
  });

  final String? receiptPath;
  final bool isPicking;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Receipt', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (receiptPath != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(receiptPath!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 140,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: isPicking ? null : onAttach,
            icon: isPicking
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.attach_file),
            label: const Text('Attach receipt'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
      ],
    );
  }
}

class _TagsField extends StatelessWidget {
  const _TagsField({
    required this.tags,
    required this.controller,
    required this.onToggle,
    required this.onAdd,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = {..._suggestedTags, ...tags}.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final tag in options)
              FilterChip(
                label: Text(tag),
                selected: tags.contains(tag),
                onSelected: (_) => onToggle(tag),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Add a tag',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onAdd(controller.text),
            ),
          ),
          onSubmitted: onAdd,
        ),
      ],
    );
  }
}
