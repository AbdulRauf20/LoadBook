import 'package:drift/drift.dart';

import '../local/database.dart';

class TransactionRepository {
  final LoadBookDatabase database;

  TransactionRepository(this.database);

  Future<int> createDailyTransaction({
    required int customerId,
    required DateTime date,
  }) {
    return database
        .into(database.dailyTransactions)
        .insert(
          DailyTransactionsCompanion.insert(
            customerId: customerId,
            transactionDate: date,
          ),
        );
  }

  Future<DailyTransaction?> getTransaction({
    required int customerId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (database.select(database.dailyTransactions)..where(
          (transaction) =>
              transaction.customerId.equals(customerId) &
              transaction.transactionDate.isBetweenValues(startOfDay, endOfDay),
        ))
        .getSingleOrNull();
  }

  Future<bool> updateLoadSent({
    required int transactionId,
    required int loadAmount,
  }) {
    return (database.update(database.dailyTransactions)
          ..where((transaction) => transaction.id.equals(transactionId)))
        .write(
          DailyTransactionsCompanion(
            loadSent: Value(loadAmount),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<List<DailyTransaction>> getTransactionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (database.select(database.dailyTransactions)..where(
          (transaction) =>
              transaction.transactionDate.isBetweenValues(startOfDay, endOfDay),
        ))
        .get();
  }

  Future<void> deleteTransactionsForCustomer(int customerId) {
    return (database.delete(database.dailyTransactions)
          ..where((transaction) => transaction.customerId.equals(customerId)))
        .go();
  }

  Future<List<DailyTransaction>> getTransactionsForCustomer(int customerId) {
    return (database.select(database.dailyTransactions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }
}
