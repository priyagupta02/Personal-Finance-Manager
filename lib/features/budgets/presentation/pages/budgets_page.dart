import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/budget.dart';
import '../cubit/budget_cubit.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/budget_list_item.dart';
import '../widgets/budget_summary_chart.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BudgetCubit>()..load(),
      child: const _BudgetsView(),
    );
  }
}

class _BudgetsView extends StatelessWidget {
  const _BudgetsView();

  Future<void> _openForm(BuildContext context, {Budget? existing}) async {
    final cubit = context.read<BudgetCubit>();
    final result = await BudgetFormSheet.show(context, existing: existing);
    if (result != null) cubit.saveBudget(result);
  }

  Future<void> _confirmDelete(BuildContext context, Budget budget) async {
    final cubit = context.read<BudgetCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text('The ${budget.category.label} budget will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.deleteBudget(budget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('New budget'),
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          switch (state.status) {
            case BudgetStatus.initial:
            case BudgetStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case BudgetStatus.error:
              return Center(
                child: Text(state.errorMessage ?? 'Could not load budgets.'),
              );
            case BudgetStatus.loaded:
              if (state.items.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                onRefresh: () => context.read<BudgetCubit>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    _Card(
                      title: 'Spent vs Remaining',
                      child: BudgetSummaryChart(
                        totalSpent: state.totalSpent,
                        totalLimit: state.totalLimit,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your budgets',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final view in state.items) ...[
                      BudgetListItem(
                        view: view,
                        onEdit: () =>
                            _openForm(context, existing: view.budget),
                        onDelete: () => _confirmDelete(context, view.budget),
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

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
            Icon(Icons.savings_outlined,
                size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            const Text(
              'No budgets yet. Tap "New budget" to set your first spending '
              'limit.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
