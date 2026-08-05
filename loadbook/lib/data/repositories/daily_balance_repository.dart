import 'package:drift/drift.dart';

import '../local/database.dart';

class DailyBalanceRepository {
  final LoadBookDatabase database;

  DailyBalanceRepository(this.database);

  /// Gets the balance record for a specific date.
  Future<DailyBalance?> getBalanceForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (database.select(database.dailyBalances)..where(
          (balance) => balance.date.isBetweenValues(startOfDay, endOfDay),
        ))
        .getSingleOrNull();
  }

  /// Creates a daily balance record.
  Future<int> createDailyBalance({
    required DateTime date,
    required int openingBalance,
  }) {
    return database
        .into(database.dailyBalances)
        .insert(
          DailyBalancesCompanion.insert(
            date: date,
            openingBalance: Value(openingBalance),
            closingBalance: Value(openingBalance),
          ),
        );
  }

  /// Updates the closing balance for a day.
  Future<bool> updateClosingBalance({
    required DateTime date,
    required int closingBalance,
  }) async {
    final balance = await getBalanceForDate(date);

    if (balance == null) {
      return false;
    }

    final rows =
        await (database.update(
          database.dailyBalances,
        )..where((table) => table.id.equals(balance.id))).write(
          DailyBalancesCompanion(
            closingBalance: Value(closingBalance),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rows > 0;
  }

  /// Gets yesterday's closing balance.
  Future<int> getPreviousClosingBalance(DateTime date) async {
    final previousDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(const Duration(days: 1));

    final balance = await getBalanceForDate(previousDay);

    return balance?.closingBalance ?? 0;
  }

  /// Gets today's opening balance.
  Future<int> getOpeningBalance(DateTime date) async {
    final balance = await getBalanceForDate(date);

    return balance?.openingBalance ?? 0;
  }
}
