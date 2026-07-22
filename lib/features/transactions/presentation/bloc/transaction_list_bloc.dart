import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/query_transactions.dart';

part 'transaction_list_event.dart';
part 'transaction_list_state.dart';

const _searchDebounce = Duration(milliseconds: 350);

/// Debounce transformer so rapid keystrokes only trigger one search, and only
/// the latest query runs to completion.
EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// Manages the transaction list: search, filters, sort, pagination, and delete.
class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  TransactionListBloc({
    required QueryTransactions queryTransactions,
    required DeleteTransaction deleteTransaction,
  })  : _queryTransactions = queryTransactions,
        _deleteTransaction = deleteTransaction,
        super(const TransactionListState()) {
    on<TransactionListStarted>(_onStarted);
    on<TransactionListRefreshed>(_onRefreshed);
    on<TransactionListNextPageRequested>(_onNextPage);
    on<TransactionSearchChanged>(_onSearchChanged, transformer: _debounce(_searchDebounce));
    on<TransactionFilterChanged>(_onFilterChanged);
    on<TransactionDeleted>(_onDeleted);
  }

  final QueryTransactions _queryTransactions;
  final DeleteTransaction _deleteTransaction;

  Future<void> _onStarted(
    TransactionListStarted event,
    Emitter<TransactionListState> emit,
  ) =>
      _loadFirstPage(state.filter, emit);

  Future<void> _onRefreshed(
    TransactionListRefreshed event,
    Emitter<TransactionListState> emit,
  ) =>
      _loadFirstPage(state.filter.copyWith(page: 0), emit);

  Future<void> _onSearchChanged(
    TransactionSearchChanged event,
    Emitter<TransactionListState> emit,
  ) =>
      _loadFirstPage(
        state.filter.copyWith(searchTerm: event.term, page: 0),
        emit,
      );

  Future<void> _onFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionListState> emit,
  ) =>
      // Preserve the active search term when filters/sort change.
      _loadFirstPage(
        event.filter.copyWith(searchTerm: state.filter.searchTerm, page: 0),
        emit,
      );

  Future<void> _loadFirstPage(
    TransactionFilter filter,
    Emitter<TransactionListState> emit,
  ) async {
    emit(state.copyWith(status: TransactionListStatus.loading, filter: filter));
    final result = await _queryTransactions(filter);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionListStatus.failure,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: TransactionListStatus.success,
        transactions: page.items,
        hasReachedMax: !page.hasMore,
        totalCount: page.totalCount,
      )),
    );
  }

  Future<void> _onNextPage(
    TransactionListNextPageRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.isLoadingMore ||
        state.status != TransactionListStatus.success) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final nextFilter = state.filter.copyWith(page: state.filter.page + 1);
    final result = await _queryTransactions(nextFilter);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        transactions: [...state.transactions, ...page.items],
        filter: nextFilter,
        hasReachedMax: !page.hasMore,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionListState> emit,
  ) async {
    final result = await _deleteTransaction(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final remaining =
            state.transactions.where((t) => t.id != event.id).toList();
        emit(state.copyWith(
          transactions: remaining,
          totalCount: (state.totalCount - 1).clamp(0, 1 << 31),
        ));
      },
    );
  }
}
