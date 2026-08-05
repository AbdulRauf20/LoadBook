import 'package:drift/drift.dart';


class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get phoneNumber => text()();

  IntColumn get monthlySales => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId => integer()();

  DateTimeColumn get transactionDate => dateTime()();

  IntColumn get loadSent => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dailyTransactionId => integer()();

  IntColumn get amount => integer()();

  DateTimeColumn get paymentDate => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class BusinessSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get businessName =>
      text().withDefault(const Constant('LoadBook'))();

  IntColumn get availableBalance => integer().withDefault(const Constant(0))();

  IntColumn get reminderHour => integer().withDefault(const Constant(18))();

  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyBalances extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();

  IntColumn get openingBalance => integer().withDefault(const Constant(0))();

  IntColumn get closingBalance => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get entityType => text()();

  IntColumn get entityId => integer()();

  TextColumn get operation => text()();

  TextColumn get payload => text()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get syncedAt => dateTime().nullable()();
}
