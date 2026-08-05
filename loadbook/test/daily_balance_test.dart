import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/daily_balance_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadBookDatabase database;
  late DailyBalanceRepository repository;

  setUp(() {
    database = LoadBookDatabase.test();
    repository = DailyBalanceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Daily balance carries yesterday closing balance into today opening balance',
    () async {
      // --------------------------------------------------
      // DAY 1
      // --------------------------------------------------

      final yesterday = DateTime(2026, 8, 4);

      // Create yesterday with Rs. 100,000 opening balance.
      await repository.createDailyBalance(
        date: yesterday,
        openingBalance: 100000,
      );

      // Yesterday ends with Rs. 80,000.
      final yesterdayUpdated = await repository.updateClosingBalance(
        date: yesterday,
        closingBalance: 80000,
      );

      expect(yesterdayUpdated, true);

      // Verify yesterday's balance.
      final yesterdayBalance = await repository.getBalanceForDate(yesterday);

      expect(yesterdayBalance, isNotNull);
      expect(yesterdayBalance!.openingBalance, 100000);
      expect(yesterdayBalance.closingBalance, 80000);

      // --------------------------------------------------
      // DAY 2
      // --------------------------------------------------

      final today = DateTime(2026, 8, 5);

      // Get yesterday's closing balance.
      final previousClosing = await repository.getPreviousClosingBalance(today);

      expect(previousClosing, 80000);

      // Create today's balance using yesterday's
      // closing balance as today's opening balance.
      await repository.createDailyBalance(
        date: today,
        openingBalance: previousClosing,
      );

      // Verify today's opening balance.
      final todayOpening = await repository.getOpeningBalance(today);

      expect(todayOpening, 80000);

      // --------------------------------------------------
      // TODAY'S ACTIVITY
      // --------------------------------------------------

      // Suppose Rs. 30,000 of load is sent and
      // Rs. 10,000 is received.
      //
      // 80,000 - 30,000 + 10,000 = 60,000

      final todayUpdated = await repository.updateClosingBalance(
        date: today,
        closingBalance: 60000,
      );

      expect(todayUpdated, true);

      // Verify today's final balance.
      final todayBalance = await repository.getBalanceForDate(today);

      expect(todayBalance, isNotNull);
      expect(todayBalance!.openingBalance, 80000);
      expect(todayBalance.closingBalance, 60000);
    },
  );

  test('Returns zero when there is no previous daily balance', () async {
    final today = DateTime(2026, 8, 5);

    final previousClosing = await repository.getPreviousClosingBalance(today);

    expect(previousClosing, 0);
  });

  test(
    'Returns zero opening balance when today has no balance record',
    () async {
      final today = DateTime(2026, 8, 5);

      final openingBalance = await repository.getOpeningBalance(today);

      expect(openingBalance, 0);
    },
  );

  test('Cannot update closing balance for a day that does not exist', () async {
    final today = DateTime(2026, 8, 5);

    final updated = await repository.updateClosingBalance(
      date: today,
      closingBalance: 50000,
    );

    expect(updated, false);
  });
}
