import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/delete_subscription.dart';
import '../../domain/usecases/get_subscriptions.dart';
import '../../domain/usecases/save_subscription.dart';

part 'subscriptions_state.dart';

/// Loads subscriptions, computes the monthly total, and builds the calendar's
/// billing-day map for the focused month.
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  SubscriptionsCubit({
    required GetSubscriptions getSubscriptions,
    required SaveSubscription saveSubscription,
    required DeleteSubscription deleteSubscription,
    required DateTime now,
  })  : _getSubscriptions = getSubscriptions,
        _saveSubscription = saveSubscription,
        _deleteSubscription = deleteSubscription,
        super(SubscriptionsState(focusedMonth: DateTime(now.year, now.month)));

  final GetSubscriptions _getSubscriptions;
  final SaveSubscription _saveSubscription;
  final DeleteSubscription _deleteSubscription;

  Future<void> load() async {
    emit(state.copyWith(status: SubscriptionsStatus.loading));
    final result = await _getSubscriptions(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: failure.message,
      )),
      (subs) {
        final sorted = [...subs]
          ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
        emit(state.copyWith(
          status: SubscriptionsStatus.loaded,
          subscriptions: sorted,
          billingDays: _billingDaysForMonth(sorted, state.focusedMonth),
        ));
      },
    );
  }

  Future<void> save(Subscription subscription) async {
    await _saveSubscription(subscription);
    await load();
  }

  Future<void> delete(String id) async {
    await _deleteSubscription(id);
    await load();
  }

  Future<void> toggleAutoRenew(Subscription subscription) =>
      save(subscription.copyWith(autoRenew: !subscription.autoRenew));

  void focusMonth(DateTime month) {
    final normalized = DateTime(month.year, month.month);
    emit(state.copyWith(
      focusedMonth: normalized,
      clearSelectedDay: true,
      billingDays: _billingDaysForMonth(state.subscriptions, normalized),
    ));
  }

  void selectDay(DateTime? day) => day == null
      ? emit(state.copyWith(clearSelectedDay: true))
      : emit(state.copyWith(selectedDay: day));

  Map<int, List<Subscription>> _billingDaysForMonth(
    List<Subscription> subs,
    DateTime month,
  ) {
    final map = <int, List<Subscription>>{};
    for (final sub in subs) {
      for (final day in _occurrencesInMonth(sub, month)) {
        map.putIfAbsent(day, () => []).add(sub);
      }
    }
    return map;
  }

  /// Days of [month] on which [sub] bills, projecting its cycle both ways.
  List<int> _occurrencesInMonth(Subscription sub, DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    // Walk back to the last occurrence before the month, then step forward
    // through it, collecting every occurrence that lands inside the month.
    var cursor = sub.nextBillingDate;
    while (!cursor.isBefore(monthStart)) {
      cursor = sub.cycle.previous(cursor);
    }
    cursor = sub.cycle.next(cursor);

    final days = <int>[];
    while (!cursor.isAfter(monthEnd)) {
      days.add(cursor.day);
      cursor = sub.cycle.next(cursor);
    }
    return days;
  }
}
