import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../cubit/home_cubit.dart';

/// Progress indicators showing spend vs limit for the top budgets.
class BudgetOverview extends StatelessWidget {
  const BudgetOverview({required this.items, super.key});

  final List<BudgetProgress> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'No budgets set yet.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: [
        for (final item in items.take(4)) _BudgetRow(item: item),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.item});

  final BudgetProgress item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = item.ratio.clamp(0.0, 1.0);
    final barColor = item.isOverBudget
        ? theme.colorScheme.error
        : (item.ratio >= 0.75 ? const Color(0xFFF2A44E) : item.budget.category.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.budget.category.icon,
                  size: 18, color: item.budget.category.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.budget.category.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${CurrencyFormatter.format(item.spent)} / '
                '${CurrencyFormatter.format(item.budget.limit)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
