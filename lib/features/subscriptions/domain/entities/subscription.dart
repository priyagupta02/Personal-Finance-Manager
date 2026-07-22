import 'package:equatable/equatable.dart';

enum BillingCycle {
  weekly,
  monthly,
  yearly;

  String get label => switch (this) {
        BillingCycle.weekly => 'Weekly',
        BillingCycle.monthly => 'Monthly',
        BillingCycle.yearly => 'Yearly',
      };

  /// Multiplier to normalize a per-cycle amount to a monthly figure.
  double get monthlyFactor => switch (this) {
        BillingCycle.weekly => 52 / 12,
        BillingCycle.monthly => 1,
        BillingCycle.yearly => 1 / 12,
      };

  /// The next billing date after [from] for this cycle.
  DateTime next(DateTime from) => switch (this) {
        BillingCycle.weekly => from.add(const Duration(days: 7)),
        BillingCycle.monthly => DateTime(from.year, from.month + 1, from.day),
        BillingCycle.yearly => DateTime(from.year + 1, from.month, from.day),
      };

  /// The billing date immediately before [from] for this cycle.
  DateTime previous(DateTime from) => switch (this) {
        BillingCycle.weekly => from.subtract(const Duration(days: 7)),
        BillingCycle.monthly => DateTime(from.year, from.month - 1, from.day),
        BillingCycle.yearly => DateTime(from.year - 1, from.month, from.day),
      };
}

/// A recurring subscription the user is tracking.
class Subscription extends Equatable {
  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    this.autoRenew = true,
  });

  final String id;
  final String name;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final bool autoRenew;

  /// Amount normalized to a monthly cost.
  double get monthlyCost => amount * cycle.monthlyFactor;

  Subscription copyWith({
    String? name,
    double? amount,
    BillingCycle? cycle,
    DateTime? nextBillingDate,
    bool? autoRenew,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, amount, cycle, nextBillingDate, autoRenew];
}
