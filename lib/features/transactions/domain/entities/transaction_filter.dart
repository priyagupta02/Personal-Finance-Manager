import 'package:equatable/equatable.dart';

import 'transaction_enums.dart';

enum TransactionSortField {
  date,
  amount;

  String get label => switch (this) {
        TransactionSortField.date => 'Date',
        TransactionSortField.amount => 'Amount',
      };
}

enum SortOrder { ascending, descending }

/// Query parameters for the transaction list: search, filters, sort, and the
/// current page. Immutable — updated via [copyWith].
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.searchTerm = '',
    this.types = const {},
    this.categories = const {},
    this.paymentMethods = const {},
    this.startDate,
    this.endDate,
    this.sortField = TransactionSortField.date,
    this.sortOrder = SortOrder.descending,
    this.page = 0,
    this.pageSize = 20,
  });

  final String searchTerm;
  final Set<TransactionType> types;
  final Set<TransactionCategory> categories;
  final Set<PaymentMethod> paymentMethods;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionSortField sortField;
  final SortOrder sortOrder;
  final int page;
  final int pageSize;

  /// True when any filter (not search/sort/paging) is applied — used to badge
  /// the filter button.
  bool get hasActiveFilters =>
      types.isNotEmpty ||
      categories.isNotEmpty ||
      paymentMethods.isNotEmpty ||
      startDate != null ||
      endDate != null;

  TransactionFilter copyWith({
    String? searchTerm,
    Set<TransactionType>? types,
    Set<TransactionCategory>? categories,
    Set<PaymentMethod>? paymentMethods,
    DateTime? startDate,
    DateTime? endDate,
    TransactionSortField? sortField,
    SortOrder? sortOrder,
    int? page,
    int? pageSize,
    bool clearDates = false,
  }) {
    return TransactionFilter(
      searchTerm: searchTerm ?? this.searchTerm,
      types: types ?? this.types,
      categories: categories ?? this.categories,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        searchTerm,
        types,
        categories,
        paymentMethods,
        startDate,
        endDate,
        sortField,
        sortOrder,
        page,
        pageSize,
      ];
}
