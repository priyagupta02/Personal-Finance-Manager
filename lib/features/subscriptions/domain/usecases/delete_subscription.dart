import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

class DeleteSubscription implements UseCase<Unit, String> {
  const DeleteSubscription(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteSubscription(id);
}
