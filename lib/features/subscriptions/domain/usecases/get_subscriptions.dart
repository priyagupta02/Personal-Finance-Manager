import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptions implements UseCase<List<Subscription>, NoParams> {
  const GetSubscriptions(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, List<Subscription>>> call(NoParams params) =>
      _repository.getSubscriptions();
}
