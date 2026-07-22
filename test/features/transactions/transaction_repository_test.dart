import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_finance_manager/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:personal_finance_manager/features/transactions/data/models/transaction_model.dart';
import 'package:personal_finance_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_enums.dart';
import 'package:personal_finance_manager/features/transactions/domain/entities/transaction_filter.dart';

class MockBox extends Mock implements Box<String> {}

void main() {
  late MockBox box;
  late TransactionRepositoryImpl repository;

  TransactionModel model({
    required String id,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
    String? title,
  }) =>
      TransactionModel(
        id: id,
        title: title ?? id,
        amount: amount,
        type: type,
        category: category,
        paymentMethod: PaymentMethod.cash,
        date: date,
      );

  setUp(() {
    box = MockBox();
    repository = TransactionRepositoryImpl(TransactionLocalDataSource(box));

    final models = [
      model(
        id: 'coffee',
        title: 'Coffee shop',
        amount: 200,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2026, 1, 10),
      ),
      model(
        id: 'salary',
        title: 'Salary',
        amount: 5000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(2026, 1, 1),
      ),
      model(
        id: 'shoes',
        title: 'Running shoes',
        amount: 3000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: DateTime(2026, 1, 20),
      ),
      model(
        id: 'lunch',
        title: 'Team lunch',
        amount: 800,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2026, 1, 15),
      ),
    ];
    when(() => box.values)
        .thenReturn(models.map((m) => jsonEncode(m.toJson())).toList());
  });

  test('filters by transaction type', () async {
    final result = await repository.queryTransactions(
      const TransactionFilter(types: {TransactionType.income}),
    );
    final page = result.getOrElse(() => throw Exception());
    expect(page.items.length, 1);
    expect(page.items.single.id, 'salary');
  });

  test('filters by category', () async {
    final result = await repository.queryTransactions(
      const TransactionFilter(categories: {TransactionCategory.food}),
    );
    final page = result.getOrElse(() => throw Exception());
    expect(page.items.map((t) => t.id), containsAll(['coffee', 'lunch']));
    expect(page.items.length, 2);
  });

  test('search matches the title (case-insensitive)', () async {
    final result = await repository.queryTransactions(
      const TransactionFilter(searchTerm: 'coffee'),
    );
    final page = result.getOrElse(() => throw Exception());
    expect(page.items.single.id, 'coffee');
  });

  test('sorts by amount ascending', () async {
    final result = await repository.queryTransactions(
      const TransactionFilter(
        sortField: TransactionSortField.amount,
        sortOrder: SortOrder.ascending,
      ),
    );
    final page = result.getOrElse(() => throw Exception());
    expect(page.items.map((t) => t.amount).toList(), [200, 800, 3000, 5000]);
  });

  test('paginates and reports hasMore', () async {
    final first = await repository.queryTransactions(
      const TransactionFilter(pageSize: 2),
    );
    final firstPage = first.getOrElse(() => throw Exception());
    expect(firstPage.items.length, 2);
    expect(firstPage.hasMore, isTrue);
    expect(firstPage.totalCount, 4);

    final second = await repository.queryTransactions(
      const TransactionFilter(pageSize: 2, page: 1),
    );
    final secondPage = second.getOrElse(() => throw Exception());
    expect(secondPage.items.length, 2);
    expect(secondPage.hasMore, isFalse);
  });
}
