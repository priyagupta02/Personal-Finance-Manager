import 'package:equatable/equatable.dart';

import 'transaction.dart';

/// A single page of query results plus whether more pages remain.
class TransactionPage extends Equatable {
  const TransactionPage({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });

  final List<Transaction> items;
  final bool hasMore;

  /// Total number of transactions matching the filter (across all pages).
  final int totalCount;

  @override
  List<Object?> get props => [items, hasMore, totalCount];
}
