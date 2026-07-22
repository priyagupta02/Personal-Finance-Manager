import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/error/failures.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/entities/subscription.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/usecases/delete_subscription.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:personal_finance_manager/features/subscriptions/domain/usecases/save_subscription.dart';
import 'package:personal_finance_manager/features/subscriptions/presentation/cubit/subscriptions_cubit.dart';

class _FakeRepo implements SubscriptionRepository {
  _FakeRepo(this._items);
  List<Subscription> _items;

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptions() async =>
      Right(_items);

  @override
  Future<Either<Failure, Unit>> saveSubscription(Subscription s) async {
    _items = [..._items.where((x) => x.id != s.id), s];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteSubscription(String id) async {
    _items = _items.where((x) => x.id != id).toList();
    return const Right(unit);
  }
}

void main() {
  final now = DateTime(2026, 6, 15);

  final netflix = Subscription(
    id: 'n',
    name: 'Netflix',
    amount: 649,
    cycle: BillingCycle.monthly,
    nextBillingDate: DateTime(2026, 6, 20),
  );
  final prime = Subscription(
    id: 'p',
    name: 'Prime',
    amount: 1200,
    cycle: BillingCycle.yearly,
    nextBillingDate: DateTime(2026, 6, 25),
  );
  final gym = Subscription(
    id: 'g',
    name: 'Gym',
    amount: 300,
    cycle: BillingCycle.weekly,
    nextBillingDate: DateTime(2026, 6, 16),
  );

  SubscriptionsCubit build(List<Subscription> subs) => SubscriptionsCubit(
        getSubscriptions: GetSubscriptions(_FakeRepo(subs)),
        saveSubscription: SaveSubscription(_FakeRepo(subs)),
        deleteSubscription: DeleteSubscription(_FakeRepo(subs)),
        now: now,
      );

  test('sorts by next billing date and totals the monthly cost', () async {
    final cubit = build([netflix, prime, gym]);
    await cubit.load();
    final s = cubit.state;

    expect(s.subscriptions.map((x) => x.id), ['g', 'n', 'p']); // 16, 20, 25
    // 649 + 1200/12 + 300*(52/12) = 649 + 100 + 1300
    expect(s.totalMonthly, closeTo(2049, 0.5));
  });

  test('calendar marks weekly occurrences and cycle-specific days', () async {
    final cubit = build([netflix, prime, gym]);
    await cubit.load();
    final days = cubit.state.billingDays;

    // Gym (weekly from the 16th) recurs on 2, 9, 16, 23, 30 in June.
    for (final d in [2, 9, 16, 23, 30]) {
      expect(days.containsKey(d), isTrue, reason: 'expected gym on $d');
    }
    expect(days[20]!.single.id, 'n'); // Netflix monthly
    expect(days[25]!.single.id, 'p'); // Prime yearly (June match)
  });

  test('yearly subscription does not recur next month', () async {
    final cubit = build([prime]);
    await cubit.load();
    cubit.focusMonth(DateTime(2026, 7));
    expect(cubit.state.billingDays.containsKey(25), isFalse);
  });

  test('toggle auto-renew persists the change', () async {
    final repo = _FakeRepo([netflix]);
    final cubit = SubscriptionsCubit(
      getSubscriptions: GetSubscriptions(repo),
      saveSubscription: SaveSubscription(repo),
      deleteSubscription: DeleteSubscription(repo),
      now: now,
    );
    await cubit.load();
    await cubit.toggleAutoRenew(netflix);
    expect(cubit.state.subscriptions.single.autoRenew, isFalse);
  });

  test('delete removes a subscription', () async {
    final repo = _FakeRepo([netflix, gym]);
    final cubit = SubscriptionsCubit(
      getSubscriptions: GetSubscriptions(repo),
      saveSubscription: SaveSubscription(repo),
      deleteSubscription: DeleteSubscription(repo),
      now: now,
    );
    await cubit.load();
    await cubit.delete('n');
    expect(cubit.state.subscriptions.map((x) => x.id), ['g']);
  });
}
