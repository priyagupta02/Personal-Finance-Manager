import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../cubit/home_cubit.dart';
import '../widgets/budget_overview.dart';
import '../widgets/quick_actions.dart';
import '../widgets/spending_chart.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthBloc, String?>((b) => b.state.user?.name);
    final firstName = (userName ?? 'there').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, $firstName 👋',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "Here's your money at a glance",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile & settings',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HomeStatus.error) {
            return _ErrorView(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () => context.read<HomeCubit>().load(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _SummaryGrid(state: state),
                const SizedBox(height: 20),
                QuickActions(
                  onAddTransaction: () async {
                    final bloc = context.read<HomeCubit>();
                    final added =
                        await context.push<bool>(AppRoutes.addTransaction);
                    if (added == true) bloc.refresh();
                  },
                  onViewReports: () => context.push(AppRoutes.analytics),
                  onScanReceipt: () async {
                    final bloc = context.read<HomeCubit>();
                    final saved =
                        await context.push<bool>(AppRoutes.receiptScanner);
                    if (saved == true) bloc.refresh();
                  },
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Monthly Spending',
                  child: SpendingChart(data: state.monthlySpending),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Recent Transactions',
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutes.transactions),
                    child: const Text('View all'),
                  ),
                  child: Column(
                    children: [
                      if (state.recentTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No transactions yet.'),
                        )
                      else
                        for (final t in state.recentTransactions)
                          TransactionTile(transaction: t),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Budget Overview',
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutes.budgets),
                    child: const Text('Manage'),
                  ),
                  child: BudgetOverview(items: state.budgetProgress),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        SummaryCard(
          label: 'Total Balance',
          value: CurrencyFormatter.format(state.totalBalance),
          icon: Icons.account_balance_wallet,
          color: AppColors.primary,
        ),
        SummaryCard(
          label: 'Monthly Income',
          value: CurrencyFormatter.format(state.monthlyIncome),
          icon: Icons.arrow_downward,
          color: AppColors.income,
        ),
        SummaryCard(
          label: 'Monthly Expenses',
          value: CurrencyFormatter.format(state.monthlyExpenses),
          icon: Icons.arrow_upward,
          color: AppColors.expense,
        ),
        SummaryCard(
          label: 'Savings Rate',
          value: '${state.savingsRate.toStringAsFixed(0)}%',
          icon: Icons.savings,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
