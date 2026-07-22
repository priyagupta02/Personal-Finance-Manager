part of 'transaction_list_bloc.dart';

sealed class TransactionListEvent extends Equatable {
  const TransactionListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the first page.
class TransactionListStarted extends TransactionListEvent {
  const TransactionListStarted();
}

/// Pull-to-refresh: reload from the first page keeping the current filter.
class TransactionListRefreshed extends TransactionListEvent {
  const TransactionListRefreshed();
}

/// Infinite scroll: load the next page and append.
class TransactionListNextPageRequested extends TransactionListEvent {
  const TransactionListNextPageRequested();
}

/// Debounced search term change.
class TransactionSearchChanged extends TransactionListEvent {
  const TransactionSearchChanged(this.term);
  final String term;

  @override
  List<Object?> get props => [term];
}

/// New filter/sort applied (search term is preserved separately).
class TransactionFilterChanged extends TransactionListEvent {
  const TransactionFilterChanged(this.filter);
  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Swipe-to-delete a transaction.
class TransactionDeleted extends TransactionListEvent {
  const TransactionDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
