part of 'transaction_list_bloc.dart';

enum TransactionListStatus { initial, loading, success, failure }

class TransactionListState extends Equatable {
  const TransactionListState({
    this.status = TransactionListStatus.initial,
    this.transactions = const [],
    this.filter = const TransactionFilter(),
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.totalCount = 0,
    this.errorMessage,
  });

  final TransactionListStatus status;
  final List<Transaction> transactions;
  final TransactionFilter filter;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int totalCount;
  final String? errorMessage;

  bool get isEmpty =>
      status == TransactionListStatus.success && transactions.isEmpty;

  TransactionListState copyWith({
    TransactionListStatus? status,
    List<Transaction>? transactions,
    TransactionFilter? filter,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? totalCount,
    String? errorMessage,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        filter,
        hasReachedMax,
        isLoadingMore,
        totalCount,
        errorMessage,
      ];
}
