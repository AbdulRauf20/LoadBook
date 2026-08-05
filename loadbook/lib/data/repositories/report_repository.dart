import 'package:drift/drift.dart';

import '../local/database.dart';

class ReportRepository {
  final LoadBookDatabase database;

  ReportRepository(this.database);

  Future<List<DailyTransaction>> getDailyTransactions(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (database.select(database.dailyTransactions)..where(
          (transaction) =>
              transaction.transactionDate.isBetweenValues(startOfDay, endOfDay),
        ))
        .get();
  }
}
