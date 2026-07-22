import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../cubit/analytics_cubit.dart';
import '../widgets/category_trend_chart.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/income_expense_line_chart.dart';
import '../widgets/insights_card.dart';
import '../widgets/monthly_comparison_chart.dart';
import '../widgets/top_categories_list.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalyticsCubit>()..load(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  Future<void> _pickCustomRange(BuildContext context) async {
    final cubit = context.read<AnalyticsCubit>();
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month - 1, now.day),
        end: now,
      ),
    );
    if (range != null) {
      cubit.customRangeChanged(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return Column(
            children: [
              _RangeSelector(
                range: state.range,
                customStart: state.customStart,
                customEnd: state.customEnd,
                onSelect: (r) {
                  if (r == AnalyticsRange.custom) {
                    _pickCustomRange(context);
                  } else {
                    context.read<AnalyticsCubit>().rangeChanged(r);
                  }
                },
              ),
              Expanded(child: _body(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, AnalyticsState state) {
    switch (state.status) {
      case AnalyticsStatus.initial:
      case AnalyticsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AnalyticsStatus.error:
        return Center(
          child: Text(state.errorMessage ?? 'Could not load analytics.'),
        );
      case AnalyticsStatus.loaded:
        if (state.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No data for this period. Try a different range.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Section(
              title: 'Expense Breakdown',
              child: ExpensePieChart(breakdown: state.categoryBreakdown),
            ),
            _Section(
              title: 'Income vs Expense Trend',
              child: IncomeExpenseLineChart(monthly: state.monthlyTotals),
            ),
            _Section(
              title: 'Monthly Comparison',
              child: MonthlyComparisonChart(monthly: state.monthlyTotals),
            ),
            _Section(
              title: 'Category Spending Over Time',
              child: CategoryTrendChart(
                months: state.months,
                series: state.categoryTrends,
              ),
            ),
            _Section(
              title: 'Top Categories',
              child: TopCategoriesList(breakdown: state.categoryBreakdown),
            ),
            _Section(
              title: 'Insights & Recommendations',
              child: InsightsList(insights: state.insights),
            ),
          ],
        );
    }
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.range,
    required this.customStart,
    required this.customEnd,
    required this.onSelect,
  });

  final AnalyticsRange range;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ValueChanged<AnalyticsRange> onSelect;

  @override
  Widget build(BuildContext context) {
    final showCustomLabel = range == AnalyticsRange.custom &&
        customStart != null &&
        customEnd != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AnalyticsRange>(
              segments: [
                for (final r in AnalyticsRange.values)
                  ButtonSegment(value: r, label: Text(r.label)),
              ],
              selected: {range},
              onSelectionChanged: (s) => onSelect(s.first),
              showSelectedIcon: false,
            ),
          ),
          if (showCustomLabel)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${DateFormat('d MMM yyyy').format(customStart!)} – '
                '${DateFormat('d MMM yyyy').format(customEnd!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
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
