import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getSubscriptions();

  Future<Either<Failure, Unit>> saveSubscription(Subscription subscription);

  Future<Either<Failure, Unit>> deleteSubscription(String id);
}
