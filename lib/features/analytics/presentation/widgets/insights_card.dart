import 'package:flutter/material.dart';

/// Renders the rule-based insights & recommendations as a bulleted list.
class InsightsList extends StatelessWidget {
  const InsightsList({required this.insights, super.key});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (insights.isEmpty) {
      return const Text('No insights available yet.');
    }
    return Column(
      children: [
        for (final insight in insights)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 18, color: theme.colorScheme.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(insight, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
