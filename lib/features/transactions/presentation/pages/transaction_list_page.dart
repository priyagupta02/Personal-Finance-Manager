import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_list_bloc.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_tile.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionListBloc>()..add(const TransactionListStarted()),
      child: const _TransactionListView(),
    );
  }
}

class _TransactionListView extends StatefulWidget {
  const _TransactionListView();

  @override
  State<_TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<_TransactionListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.offset >= threshold) {
      context
          .read<TransactionListBloc>()
          .add(const TransactionListNextPageRequested());
    }
  }

  Future<void> _openFilters() async {
    final bloc = context.read<TransactionListBloc>();
    final updated =
        await TransactionFilterSheet.show(context, bloc.state.filter);
    if (updated != null) {
      bloc.add(TransactionFilterChanged(updated));
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Transaction t) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${t.title}" will be permanently removed.'),
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
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          BlocBuilder<TransactionListBloc, TransactionListState>(
            buildWhen: (a, b) =>
                a.filter.hasActiveFilters != b.filter.hasActiveFilters,
            builder: (context, state) {
              return IconButton(
                tooltip: 'Filter & sort',
                onPressed: _openFilters,
                icon: Badge(
                  isLabelVisible: state.filter.hasActiveFilters,
                  child: const Icon(Icons.tune),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (term) => context
                  .read<TransactionListBloc>()
                  .add(TransactionSearchChanged(term)),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TransactionListBloc, TransactionListState>(
        builder: (context, state) {
          switch (state.status) {
            case TransactionListStatus.initial:
            case TransactionListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case TransactionListStatus.failure:
              return _Message(
                icon: Icons.error_outline,
                text: state.errorMessage ?? 'Could not load transactions.',
              );
            case TransactionListStatus.success:
              if (state.transactions.isEmpty) {
                return const _Message(
                  icon: Icons.receipt_long_outlined,
                  text: 'No transactions match your filters.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TransactionListBloc>()
                      .add(const TransactionListRefreshed());
                },
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.transactions.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= state.transactions.length) {
                      return _Footer(state: state);
                    }
                    final t = state.transactions[index];
                    return _SwipeableRow(
                      transaction: t,
                      confirmDelete: () => _confirmDelete(context, t),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

/// A transaction row with swipe-right to edit and swipe-left to delete.
class _SwipeableRow extends StatelessWidget {
  const _SwipeableRow({required this.transaction, required this.confirmDelete});

  final Transaction transaction;
  final Future<bool> Function() confirmDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(transaction.id),
      background: _swipeBg(
        color: theme.colorScheme.primary,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBg(
        color: theme.colorScheme.error,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final bloc = context.read<TransactionListBloc>();
          final changed = await context.push<bool>(
            AppRoutes.editTransaction,
            extra: transaction,
          );
          if (changed == true) {
            bloc.add(const TransactionListRefreshed());
          }
          return false;
        }
        return confirmDelete();
      },
      onDismissed: (_) => context
          .read<TransactionListBloc>()
          .add(TransactionDeleted(transaction.id)),
      child: TransactionTile(transaction: transaction),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});
  final TransactionListState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Text(
          '${state.totalCount} transaction${state.totalCount == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // ListView so pull-to-refresh still works on empty/error states.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center),
      ],
    );
  }
}
