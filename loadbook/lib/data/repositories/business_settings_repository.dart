import 'package:drift/drift.dart';

import '../local/database.dart';

class BusinessSettingsRepository {
  final LoadBookDatabase database;

  BusinessSettingsRepository(this.database);

  Future<BusinessSetting?> getSettings() {
    return (database.select(
      database.businessSettings,
    )..limit(1)).getSingleOrNull();
  }

  Future<int> getAvailableBalance() async {
    final settings = await getSettings();

    return settings?.availableBalance ?? 0;
  }

  Future<void> setAvailableBalance(int balance) async {
    final existing = await getSettings();

    if (existing == null) {
      await database
          .into(database.businessSettings)
          .insert(
            BusinessSettingsCompanion.insert(availableBalance: Value(balance)),
          );

      return;
    }

    await (database.update(
      database.businessSettings,
    )..where((table) => table.id.equals(existing.id))).write(
      BusinessSettingsCompanion(
        availableBalance: Value(balance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> increaseBalance(int amount) async {
    final current = await getAvailableBalance();

    await setAvailableBalance(current + amount);
  }

  Future<void> decreaseBalance(int amount) async {
    final current = await getAvailableBalance();

    await setAvailableBalance(current - amount);
  }
}
