import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/subscription.dart';

/// Lightweight month calendar marking days with subscription renewals.
class SubscriptionCalendar extends StatelessWidget {
  const SubscriptionCalendar({
    required this.month,
    required this.billingDays,
    required this.selectedDay,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDay,
    super.key,
  });

  final DateTime month;
  final Map<int, List<Subscription>> billingDays;
  final DateTime? selectedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        Row(
          children: [
            for (final d in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                day: day,
                hasBilling: billingDays.containsKey(day),
                isSelected: selectedDay != null &&
                    selectedDay!.year == month.year &&
                    selectedDay!.month == month.month &&
                    selectedDay!.day == day,
                onTap: () => onSelectDay(DateTime(month.year, month.month, day)),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.hasBilling,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final bool hasBilling;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimary : null,
                fontWeight: hasBilling ? FontWeight.bold : null,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasBilling && !isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
