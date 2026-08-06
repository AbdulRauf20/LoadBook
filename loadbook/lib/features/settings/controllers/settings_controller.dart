import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../data/local/database.dart';

class SettingsController extends ChangeNotifier {
  final LoadBookDatabase database;

  SettingsController(this.database);

  BusinessSetting? settings;

  Future<void> load() async {
    final list = await database.select(database.businessSettings).get();

    if (list.isEmpty) {
      await database
          .into(database.businessSettings)
          .insert(BusinessSettingsCompanion.insert());

      settings = await database.select(database.businessSettings).getSingle();
    } else {
      settings = list.first;
    }

    notifyListeners();
  }

  Future<void> save({
    required String businessName,
    required int availableBalance,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    await (database.update(
      database.businessSettings,
    )..where((tbl) => tbl.id.equals(settings!.id))).write(
      BusinessSettingsCompanion(
        businessName: Value(businessName),
        availableBalance: Value(availableBalance),
        reminderHour: Value(reminderHour),
        reminderMinute: Value(reminderMinute),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await load();
  }
}
