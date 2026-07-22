import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/subscription.dart';
import 'service_avatar.dart';

/// A subscription row: logo, name, next-billing info, amount, auto-renew, and
/// an in-app renewal reminder when it's due soon.
class SubscriptionListItem extends StatelessWidget {
  const SubscriptionListItem({
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAutoRenew,
    super.key,
  });

  final Subscription subscription;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleAutoRenew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final daysUntil = DateTime(
      subscription.nextBillingDate.year,
      subscription.nextBillingDate.month,
      subscription.nextBillingDate.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    final dueSoon = daysUntil >= 0 && daysUntil <= 3;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ServiceAvatar(name: subscription.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${subscription.cycle.label} · next '
                      '${DateFormat('d MMM').format(subscription.nextBillingDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(subscription.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '/${subscription.cycle.label.toLowerCase()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
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
          Row(
            children: [
              if (dueSoon)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2A44E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active,
                          size: 14, color: Color(0xFFF2A44E)),
                      const SizedBox(width: 4),
                      Text(
                        daysUntil == 0
                            ? 'Renews today'
                            : 'Renews in $daysUntil day${daysUntil == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFF2A44E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text('Auto-renew', style: theme.textTheme.bodySmall),
              Switch(
                value: subscription.autoRenew,
                onChanged: onToggleAutoRenew,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
