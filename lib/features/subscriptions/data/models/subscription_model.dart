import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.cycle,
    required super.nextBillingDate,
    super.autoRenew,
  });

  factory SubscriptionModel.fromEntity(Subscription s) => SubscriptionModel(
        id: s.id,
        name: s.name,
        amount: s.amount,
        cycle: s.cycle,
        nextBillingDate: s.nextBillingDate,
        autoRenew: s.autoRenew,
      );

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        cycle: BillingCycle.values.byName(json['cycle'] as String),
        nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
        autoRenew: json['autoRenew'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'cycle': cycle.name,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'autoRenew': autoRenew,
      };
}
