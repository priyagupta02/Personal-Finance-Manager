part of 'analytics_cubit.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

/// Selectable reporting window.
enum AnalyticsRange {
  thisMonth,
  last3Months,
  custom;

  String get label => switch (this) {
        AnalyticsRange.thisMonth => 'This Month',
        AnalyticsRange.last3Months => 'Last 3 Months',
        AnalyticsRange.custom => 'Custom',
      };
}

/// Total expense for one category over the selected range.
class CategoryAmount extends Equatable {
  const CategoryAmount({
    required this.category,
    required this.amount,
    required this.share,
  });

  final TransactionCategory category;
  final double amount;

  /// Fraction of total expense (0–1).
  final double share;

  @override
  List<Object?> get props => [category, amount, share];
}

/// Income and expense totals for a single month.
class MonthlyTotals extends Equatable {
  const MonthlyTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;

  @override
  List<Object?> get props => [month, income, expense];
}

/// A category's monthly expense series, aligned with [AnalyticsState.months].
class CategorySeries extends Equatable {
  const CategorySeries({required this.category, required this.monthlyExpense});

  final TransactionCategory category;
  final List<double> monthlyExpense;

  @override
  List<Object?> get props => [category, monthlyExpense];
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.range = AnalyticsRange.last3Months,
    this.customStart,
    this.customEnd,
    this.months = const [],
    this.monthlyTotals = const [],
    this.categoryBreakdown = const [],
    this.categoryTrends = const [],
    this.insights = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final AnalyticsRange range;
  final DateTime? customStart;
  final DateTime? customEnd;

  final List<DateTime> months;
  final List<MonthlyTotals> monthlyTotals;
  final List<CategoryAmount> categoryBreakdown;
  final List<CategorySeries> categoryTrends;
  final List<String> insights;
  final double totalIncome;
  final double totalExpense;
  final String? errorMessage;

  bool get isEmpty =>
      status == AnalyticsStatus.loaded &&
      totalIncome == 0 &&
      totalExpense == 0;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsRange? range,
    DateTime? customStart,
    DateTime? customEnd,
    List<DateTime>? months,
    List<MonthlyTotals>? monthlyTotals,
    List<CategoryAmount>? categoryBreakdown,
    List<CategorySeries>? categoryTrends,
    List<String>? insights,
    double? totalIncome,
    double? totalExpense,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      range: range ?? this.range,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      months: months ?? this.months,
      monthlyTotals: monthlyTotals ?? this.monthlyTotals,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      categoryTrends: categoryTrends ?? this.categoryTrends,
      insights: insights ?? this.insights,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        range,
        customStart,
        customEnd,
        months,
        monthlyTotals,
        categoryBreakdown,
        categoryTrends,
        insights,
        totalIncome,
        totalExpense,
        errorMessage,
      ];
}
