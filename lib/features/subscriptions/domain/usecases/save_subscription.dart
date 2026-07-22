import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class SaveSubscription implements UseCase<Unit, Subscription> {
  const SaveSubscription(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Subscription subscription) =>
      _repository.saveSubscription(subscription);
}
