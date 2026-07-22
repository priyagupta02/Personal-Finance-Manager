import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../cubit/budget_cubit.dart';

/// A budget card: category, progress bar with alert-threshold marker,
/// budget-vs-actual figures, and rollover/alert badges.
class BudgetListItem extends StatelessWidget {
  const BudgetListItem({
    required this.view,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final BudgetView view;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = view.budget;
    final ratio = view.ratio.clamp(0.0, 1.0);
    final barColor = view.isOverBudget
        ? theme.colorScheme.error
        : (view.alertReached ? const Color(0xFFF2A44E) : budget.category.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: budget.category.color.withValues(alpha: 0.15),
                foregroundColor: budget.category.color,
                child: Icon(budget.category.icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      budget.period.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar with the alert-threshold marker.
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(barColor),
                    ),
                  ),
                  Positioned(
                    left: width * (budget.alertThreshold / 100) - 1,
                    child: Container(
                      width: 2,
                      height: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Budget vs actual.
              Text(
                '${CurrencyFormatter.format(view.spent)} of '
                '${CurrencyFormatter.format(view.effectiveLimit)}',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                view.isOverBudget
                    ? '${CurrencyFormatter.format(view.spent - view.effectiveLimit)} over'
                    : '${CurrencyFormatter.format(view.remaining)} left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: view.isOverBudget ? theme.colorScheme.error : null,
                ),
              ),
            ],
          ),
          if (view.rolloverAmount > 0 || view.alertReached) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (view.rolloverAmount > 0)
                  _Badge(
                    icon: Icons.history,
                    label:
                        '+${CurrencyFormatter.format(view.rolloverAmount)} rolled over',
                    color: theme.colorScheme.primary,
                  ),
                if (view.alertReached)
                  _Badge(
                    icon: Icons.notifications_active,
                    label: '${budget.alertThreshold}% alert reached',
                    color: view.isOverBudget
                        ? theme.colorScheme.error
                        : const Color(0xFFF2A44E),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
