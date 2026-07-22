import 'package:flutter/material.dart';

/// Row of primary shortcuts on the dashboard.
class QuickActions extends StatelessWidget {
  const QuickActions({
    required this.onAddTransaction,
    required this.onViewReports,
    required this.onScanReceipt,
    super.key,
  });

  final VoidCallback onAddTransaction;
  final VoidCallback onViewReports;
  final VoidCallback onScanReceipt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: Icons.add_circle_outline,
          label: 'Add',
          onTap: onAddTransaction,
        ),
        _Action(
          icon: Icons.bar_chart,
          label: 'Reports',
          onTap: onViewReports,
        ),
        _Action(
          icon: Icons.document_scanner_outlined,
          label: 'Scan',
          onTap: onScanReceipt,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
