import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Donut chart showing total spent vs remaining across all budgets — the
/// spec's "chart showing spent vs remaining".
class BudgetSummaryChart extends StatelessWidget {
  const BudgetSummaryChart({
    required this.totalSpent,
    required this.totalLimit,
    super.key,
  });

  final double totalSpent;
  final double totalLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (totalLimit - totalSpent).clamp(0, double.infinity);
    final overspent = totalSpent > totalLimit;
    final spentColor = overspent ? theme.colorScheme.error : AppColors.primary;

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    PieChartSectionData(
                      value: totalSpent <= 0 ? 1 : totalSpent,
                      color: spentColor,
                      radius: 18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: remaining <= 0 ? 0.0001 : remaining.toDouble(),
                      color: theme.colorScheme.surfaceContainerHighest,
                      radius: 18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Spent', style: theme.textTheme.bodySmall),
                  Text(
                    CurrencyFormatter.format(totalSpent),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(
                color: spentColor,
                label: 'Spent',
                value: CurrencyFormatter.format(totalSpent),
              ),
              const SizedBox(height: 12),
              _Legend(
                color: theme.colorScheme.surfaceContainerHighest,
                label: overspent ? 'Over budget' : 'Remaining',
                value: overspent
                    ? CurrencyFormatter.format(totalSpent - totalLimit)
                    : CurrencyFormatter.format(remaining.toDouble()),
              ),
              const SizedBox(height: 12),
              _Legend(
                color: theme.colorScheme.outline,
                label: 'Total budget',
                value: CurrencyFormatter.format(totalLimit),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
