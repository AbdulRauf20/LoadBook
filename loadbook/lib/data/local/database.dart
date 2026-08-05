import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'database_tables.dart';

part "database.g.dart";

@DriftDatabase(
  tables: [
    Customers,
    DailyTransactions,
    Payments,
    BusinessSettings,
    DailyBalances,
    SyncQueue,
  ],
)
class LoadBookDatabase extends _$LoadBookDatabase {
  LoadBookDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/loadbook.sqlite');

    return NativeDatabase.createInBackground(file);
  });
}
