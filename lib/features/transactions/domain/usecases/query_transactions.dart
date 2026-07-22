import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction_filter.dart';
import '../entities/transaction_page.dart';
import '../repositories/transaction_repository.dart';

/// Returns a filtered/sorted/paginated page of transactions.
class QueryTransactions implements UseCase<TransactionPage, TransactionFilter> {
  const QueryTransactions(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, TransactionPage>> call(TransactionFilter filter) =>
      _repository.queryTransactions(filter);
}
