import '../local/database.dart';

class BalanceRepository {
  final LoadBookDatabase database;

  BalanceRepository(this.database);

  Future<int> getTotalLoadSent() async {
    final result = await database.customSelect('''
      SELECT COALESCE(SUM(load_sent), 0) AS total
      FROM daily_transactions
      ''').getSingle();

    return result.read<int>('total');
  }

  Future<int> getTotalReceived() async {
    final result = await database.customSelect('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payments
      ''').getSingle();

    return result.read<int>('total');
  }

  Future<int> calculateAvailableBalance({required int openingBalance}) async {
    final totalSent = await getTotalLoadSent();
    final totalReceived = await getTotalReceived();

    return openingBalance + totalReceived - totalSent;
  }
}
