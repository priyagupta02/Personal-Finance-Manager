part of 'subscriptions_cubit.dart';

enum SubscriptionsStatus { initial, loading, loaded, error }

class SubscriptionsState extends Equatable {
  const SubscriptionsState({
    this.status = SubscriptionsStatus.initial,
    this.subscriptions = const [],
    required this.focusedMonth,
    this.selectedDay,
    this.billingDays = const {},
    this.errorMessage,
  });

  final SubscriptionsStatus status;

  /// Sorted by soonest next billing date.
  final List<Subscription> subscriptions;

  /// Month currently shown in the calendar.
  final DateTime focusedMonth;
  final DateTime? selectedDay;

  /// Day-of-month → subscriptions billing that day (for [focusedMonth]).
  final Map<int, List<Subscription>> billingDays;

  final String? errorMessage;

  double get totalMonthly =>
      subscriptions.fold(0, (sum, s) => sum + s.monthlyCost);

  SubscriptionsState copyWith({
    SubscriptionsStatus? status,
    List<Subscription>? subscriptions,
    DateTime? focusedMonth,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
    Map<int, List<Subscription>>? billingDays,
    String? errorMessage,
  }) {
    return SubscriptionsState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      billingDays: billingDays ?? this.billingDays,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subscriptions,
        focusedMonth,
        selectedDay,
        billingDays,
        errorMessage,
      ];
}
