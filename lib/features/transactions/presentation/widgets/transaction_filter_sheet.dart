import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction_enums.dart';
import '../../domain/entities/transaction_filter.dart';

/// Bottom sheet for filtering and sorting the transaction list. Returns the
/// updated [TransactionFilter] via `Navigator.pop`, or null if dismissed.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({required this.initial, super.key});

  final TransactionFilter initial;

  static Future<TransactionFilter?> show(
    BuildContext context,
    TransactionFilter initial,
  ) {
    return showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TransactionFilterSheet(initial: initial),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<TransactionType> _types = {...widget.initial.types};
  late Set<TransactionCategory> _categories = {...widget.initial.categories};
  late Set<PaymentMethod> _methods = {...widget.initial.paymentMethods};
  late DateTime? _startDate = widget.initial.startDate;
  late DateTime? _endDate = widget.initial.endDate;
  late TransactionSortField _sortField = widget.initial.sortField;
  late SortOrder _sortOrder = widget.initial.sortOrder;

  void _reset() {
    setState(() {
      _types = {};
      _categories = {};
      _methods = {};
      _startDate = null;
      _endDate = null;
      _sortField = TransactionSortField.date;
      _sortOrder = SortOrder.descending;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      widget.initial.copyWith(
        types: _types,
        categories: _categories,
        paymentMethods: _methods,
        startDate: _startDate,
        endDate: _endDate,
        sortField: _sortField,
        sortOrder: _sortOrder,
        clearDates: _startDate == null && _endDate == null,
        page: 0,
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = DateTime(range.start.year, range.start.month, range.start.day);
        _endDate = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _startDate != null && _endDate != null
        ? '${DateFormat('d MMM').format(_startDate!)} – '
            '${DateFormat('d MMM').format(_endDate!)}'
        : 'Any date';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Filter & Sort',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 8),
            _Label('Sort by'),
            Row(
              children: [
                for (final field in TransactionSortField.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(field.label),
                      selected: _sortField == field,
                      onSelected: (_) => setState(() => _sortField = field),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: _sortOrder == SortOrder.descending
                      ? 'Descending'
                      : 'Ascending',
                  icon: Icon(_sortOrder == SortOrder.descending
                      ? Icons.arrow_downward
                      : Icons.arrow_upward),
                  onPressed: () => setState(() {
                    _sortOrder = _sortOrder == SortOrder.descending
                        ? SortOrder.ascending
                        : SortOrder.descending;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Label('Type'),
            Wrap(
              spacing: 8,
              children: [
                for (final type in TransactionType.values)
                  FilterChip(
                    label: Text(type.label),
                    selected: _types.contains(type),
                    onSelected: (sel) => setState(() =>
                        sel ? _types.add(type) : _types.remove(type)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Label('Payment method'),
            Wrap(
              spacing: 8,
              children: [
                for (final m in PaymentMethod.values)
                  FilterChip(
                    label: Text(m.label),
                    selected: _methods.contains(m),
                    onSelected: (sel) => setState(
                        () => sel ? _methods.add(m) : _methods.remove(m)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Label('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in TransactionCategory.values)
                  FilterChip(
                    label: Text(c.label),
                    selected: _categories.contains(c),
                    onSelected: (sel) => setState(() =>
                        sel ? _categories.add(c) : _categories.remove(c)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Label('Date range'),
            OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(dateLabel),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _apply,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
}
