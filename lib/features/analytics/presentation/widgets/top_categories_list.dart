import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../cubit/analytics_cubit.dart';

/// Ranked list of the top spending categories with share bars.
class TopCategoriesList extends StatelessWidget {
  const TopCategoriesList({required this.breakdown, super.key});

  final List<CategoryAmount> breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return const Text('No spending to rank yet.');
    }
    final top = breakdown.take(5).toList();
    return Column(
      children: [
        for (final c in top)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(c.category.icon, size: 18, color: c.category.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.category.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.format(c.amount)} · '
                      '${(c.share * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: c.share.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(c.category.color),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
