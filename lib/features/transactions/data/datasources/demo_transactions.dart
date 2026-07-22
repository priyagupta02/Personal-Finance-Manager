import '../../domain/entities/transaction_enums.dart';
import '../models/transaction_model.dart';

/// Seed data used on first launch so the dashboard/analytics have something to
/// show before the user adds their own transactions. Dates are relative to
/// "now" so charts always look current.
List<TransactionModel> buildDemoTransactions() {
  final now = DateTime.now();
  DateTime day(int monthsAgo, int day) =>
      DateTime(now.year, now.month - monthsAgo, day);

  var counter = 0;
  String nextId() => 'seed-${counter++}';

  return [
    // --- This month ------------------------------------------------------
    TransactionModel(
      id: nextId(),
      title: 'Monthly Salary',
      amount: 85000,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(0, 1),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Rent',
      amount: 22000,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(0, 2),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Groceries - BigBasket',
      amount: 3450,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      paymentMethod: PaymentMethod.upi,
      date: day(0, 4),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Dinner with friends',
      amount: 1800,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      paymentMethod: PaymentMethod.card,
      date: day(0, 6),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Uber rides',
      amount: 920,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      paymentMethod: PaymentMethod.upi,
      date: day(0, 7),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Netflix',
      amount: 649,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      paymentMethod: PaymentMethod.card,
      date: day(0, 8),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'New headphones',
      amount: 4999,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      paymentMethod: PaymentMethod.card,
      date: day(0, 9),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Freelance project',
      amount: 15000,
      type: TransactionType.income,
      category: TransactionCategory.investment,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(0, 10),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Pharmacy',
      amount: 760,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      paymentMethod: PaymentMethod.cash,
      date: day(0, 11),
    ),

    // --- Last month ------------------------------------------------------
    TransactionModel(
      id: nextId(),
      title: 'Monthly Salary',
      amount: 85000,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(1, 1),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Rent',
      amount: 22000,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(1, 2),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Online course',
      amount: 3999,
      type: TransactionType.expense,
      category: TransactionCategory.education,
      paymentMethod: PaymentMethod.card,
      date: day(1, 12),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Groceries',
      amount: 4100,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      paymentMethod: PaymentMethod.upi,
      date: day(1, 15),
    ),
    TransactionModel(
      id: nextId(),
      title: 'Weekend trip',
      amount: 6500,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      paymentMethod: PaymentMethod.card,
      date: day(1, 20),
    ),

    // --- Two months ago --------------------------------------------------
    TransactionModel(
      id: nextId(),
      title: 'Monthly Salary',
      amount: 82000,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(2, 1),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Rent',
      amount: 22000,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      paymentMethod: PaymentMethod.bankTransfer,
      date: day(2, 2),
      isRecurring: true,
    ),
    TransactionModel(
      id: nextId(),
      title: 'Electronics',
      amount: 12500,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      paymentMethod: PaymentMethod.card,
      date: day(2, 14),
    ),
  ];
}
