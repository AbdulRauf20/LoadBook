import 'package:flutter_test/flutter_test.dart';
import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/features/daily/controllers/daily_controller.dart';

void main() {
  late LoadBookDatabase database;
  late DailyController controller;

  setUp(() {
    database = LoadBookDatabase.test();
    controller = DailyController(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('controller creates transaction and records payment', () async {
    final customerId = await controller.customerRepository.addCustomer(
      name: 'Test Shop',
      phoneNumber: '03000000000',
      monthlySales: 100000,
    );

    await controller.loadDay(DateTime(2026, 8, 5));

    await controller.setLoadAmount(customerId: customerId, amount: 20000);

    await controller.addPayment(customerId: customerId, amount: 5000);

    final transactions = await controller.transactionRepository
        .getTransactionsForDate(DateTime(2026, 8, 5));

    expect(transactions.length, 1);
    expect(transactions.first.loadSent, 20000);

    final received = await controller.getAmountReceived(transactions.first.id);

    expect(received, 5000);

    final remaining = await controller.getRemainingAmount(transactions.first);

    expect(remaining, 15000);
  });
}
