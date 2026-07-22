import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../../domain/entities/budget.dart';

/// Bottom sheet to create or edit a [Budget]. Returns the budget via
/// `Navigator.pop`, or null if dismissed.
class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({this.existing, super.key});

  final Budget? existing;

  static Future<Budget?> show(BuildContext context, {Budget? existing}) {
    return showModalBottomSheet<Budget>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BudgetFormSheet(existing: existing),
    );
  }

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;

  late TransactionCategory _category;
  late BudgetPeriod _period;
  late int _alertThreshold;
  late bool _rollover;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _limitController = TextEditingController(
      text: b != null ? b.limit.toStringAsFixed(0) : '',
    );
    _category = b?.category ?? TransactionCategory.food;
    _period = b?.period ?? BudgetPeriod.monthly;
    _alertThreshold = b?.alertThreshold ?? 90;
    _rollover = b?.rollover ?? false;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      Budget(
        id: widget.existing?.id ?? IdGenerator.generate(),
        category: _category,
        limit: double.parse(_limitController.text.trim()),
        period: _period,
        alertThreshold: _alertThreshold,
        rollover: _rollover,
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
                isEditing ? 'Edit budget' : 'New budget',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                initialValue: _category,
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
                onChanged: (c) => c != null ? setState(() => _category = c) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: Validators.amount,
                decoration: InputDecoration(
                  labelText: 'Limit',
                  prefixText: '${CurrencyFormatter.defaultSymbol} ',
                ),
              ),
              const SizedBox(height: 16),
              Text('Period', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<BudgetPeriod>(
                segments: [
                  for (final p in BudgetPeriod.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() => _period = s.first),
              ),
              const SizedBox(height: 16),
              Text('Alert me at', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in kAlertThresholds)
                    ChoiceChip(
                      label: Text('$t%'),
                      selected: _alertThreshold == t,
                      onSelected: (_) => setState(() => _alertThreshold = t),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Roll over unused budget'),
                subtitle: const Text(
                  "Add last period's leftover to this period",
                ),
                value: _rollover,
                onChanged: (v) => setState(() => _rollover = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Create budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
