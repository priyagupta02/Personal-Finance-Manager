import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/subscription.dart';
import '../cubit/subscriptions_cubit.dart';
import '../widgets/service_avatar.dart';
import '../widgets/subscription_calendar.dart';
import '../widgets/subscription_form_sheet.dart';
import '../widgets/subscription_list_item.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..load(),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView();

  Future<void> _openForm(BuildContext context, {Subscription? existing}) async {
    final cubit = context.read<SubscriptionsCubit>();
    final result = await SubscriptionFormSheet.show(context, existing: existing);
    if (result != null) cubit.save(result);
  }

  Future<void> _confirmDelete(BuildContext context, Subscription s) async {
    final cubit = context.read<SubscriptionsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subscription?'),
        content: Text('${s.name} will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) cubit.delete(s.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          switch (state.status) {
            case SubscriptionsStatus.initial:
            case SubscriptionsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case SubscriptionsStatus.error:
              return Center(child: Text(state.errorMessage ?? 'Error'));
            case SubscriptionsStatus.loaded:
              if (state.subscriptions.isEmpty) {
                return const _EmptyState();
              }
              final cubit = context.read<SubscriptionsCubit>();
              final selectedDaySubs = state.selectedDay == null
                  ? const <Subscription>[]
                  : (state.billingDays[state.selectedDay!.day] ??
                      const <Subscription>[]);
              return RefreshIndicator(
                onRefresh: () => cubit.load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    _TotalCard(
                      total: state.totalMonthly,
                      count: state.subscriptions.length,
                    ),
                    const SizedBox(height: 16),
                    _Card(
                      child: Column(
                        children: [
                          SubscriptionCalendar(
                            month: state.focusedMonth,
                            billingDays: state.billingDays,
                            selectedDay: state.selectedDay,
                            onPrev: () => cubit.focusMonth(DateTime(
                                state.focusedMonth.year,
                                state.focusedMonth.month - 1)),
                            onNext: () => cubit.focusMonth(DateTime(
                                state.focusedMonth.year,
                                state.focusedMonth.month + 1)),
                            onSelectDay: cubit.selectDay,
                          ),
                          if (state.selectedDay != null) ...[
                            const Divider(height: 24),
                            _DayDetails(
                              day: state.selectedDay!,
                              subs: selectedDaySubs,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your subscriptions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final s in state.subscriptions) ...[
                      SubscriptionListItem(
                        subscription: s,
                        onEdit: () => _openForm(context, existing: s),
                        onDelete: () => _confirmDelete(context, s),
                        onToggleAutoRenew: (_) => cubit.toggleAutoRenew(s),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total per month',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(total),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count active subscription${count == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.day, required this.subs});

  final DateTime day;
  final List<Subscription> subs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('d MMMM').format(day),
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (subs.isEmpty)
          Text('No renewals on this day.', style: theme.textTheme.bodySmall)
        else
          for (final s in subs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  ServiceAvatar(name: s.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.name)),
                  Text(CurrencyFormatter.format(s.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subscriptions_outlined,
                size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            const Text(
              'No subscriptions yet. Tap "Add" to track your first one.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
