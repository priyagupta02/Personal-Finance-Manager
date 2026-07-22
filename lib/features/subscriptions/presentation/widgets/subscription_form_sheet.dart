import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/subscription.dart';

/// Bottom sheet to create or edit a [Subscription].
class SubscriptionFormSheet extends StatefulWidget {
  const SubscriptionFormSheet({this.existing, super.key});

  final Subscription? existing;

  static Future<Subscription?> show(BuildContext context, {Subscription? existing}) {
    return showModalBottomSheet<Subscription>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SubscriptionFormSheet(existing: existing),
    );
  }

  @override
  State<SubscriptionFormSheet> createState() => _SubscriptionFormSheetState();
}

class _SubscriptionFormSheetState extends State<SubscriptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  late BillingCycle _cycle;
  late DateTime _nextBillingDate;
  late bool _autoRenew;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameController = TextEditingController(text: s?.name ?? '');
    _amountController =
        TextEditingController(text: s != null ? s.amount.toStringAsFixed(0) : '');
    _cycle = s?.cycle ?? BillingCycle.monthly;
    _nextBillingDate =
        s?.nextBillingDate ?? DateTime.now().add(const Duration(days: 30));
    _autoRenew = s?.autoRenew ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) setState(() => _nextBillingDate = date);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      Subscription(
        id: widget.existing?.id ?? IdGenerator.generate(),
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        cycle: _cycle,
        nextBillingDate: _nextBillingDate,
        autoRenew: _autoRenew,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit subscription' : 'New subscription',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Name'),
                decoration: const InputDecoration(labelText: 'Service name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: Validators.amount,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${CurrencyFormatter.activeSymbol} ',
                ),
              ),
              const SizedBox(height: 16),
              Text('Billing cycle', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<BillingCycle>(
                segments: [
                  for (final c in BillingCycle.values)
                    ButtonSegment(value: c, label: Text(c.label)),
                ],
                selected: {_cycle},
                onSelectionChanged: (s) => setState(() => _cycle = s.first),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next billing date',
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(
                    DateFormat('EEE, d MMM yyyy').format(_nextBillingDate),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-renewal'),
                value: _autoRenew,
                onChanged: (v) => setState(() => _autoRenew = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Add subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
