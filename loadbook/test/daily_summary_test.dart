import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/customer_repository.dart';
import 'package:loadbook/data/repositories/payment_repository.dart';
import 'package:loadbook/data/repositories/transaction_repository.dart';
import 'package:loadbook/features/daily/controllers/daily_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadBookDatabase database;
  late CustomerRepository customerRepository;
  late TransactionRepository transactionRepository;
  late PaymentRepository paymentRepository;
  late DailyController dailyController;

  setUp(() {
    database = LoadBookDatabase.test();

    customerRepository = CustomerRepository(database);
    transactionRepository = TransactionRepository(database);
    paymentRepository = PaymentRepository(database);

    dailyController = DailyController(database);
  });

  tearDown(() async {
    dailyController.dispose();
    await database.close();
  });

  test(
    'Daily summary calculates sent, received, remaining and status correctly',
    () async {
      // --------------------------------------------------
      // 1. Add customers
      // --------------------------------------------------

      await customerRepository.addCustomer(
        name: 'Ali Mobile',
        phoneNumber: '03001234567',
      );

      await customerRepository.addCustomer(
        name: 'Bilal Mobile',
        phoneNumber: '03007654321',
      );

      // --------------------------------------------------
      // 2. Load today's customers
      // --------------------------------------------------

      await dailyController.loadDay(DateTime.now());

      expect(dailyController.customers.length, 2);

      final ali = dailyController.customers.firstWhere(
        (customer) => customer.name == 'Ali Mobile',
      );

      final bilal = dailyController.customers.firstWhere(
        (customer) => customer.name == 'Bilal Mobile',
      );

      // --------------------------------------------------
      // 3. Create today's transactions
      // --------------------------------------------------

      final aliTransactionId =
          await transactionRepository.createDailyTransaction(
        customerId: ali.id,
        date: DateTime.now(),
      );

      await transactionRepository.updateLoadSent(
        transactionId: aliTransactionId,
        loadAmount: 20000,
      );

      final bilalTransactionId =
          await transactionRepository.createDailyTransaction(
        customerId: bilal.id,
        date: DateTime.now(),
      );

      await transactionRepository.updateLoadSent(
        transactionId: bilalTransactionId,
        loadAmount: 15000,
      );

      // --------------------------------------------------
      // 4. Record payments
      // --------------------------------------------------

      // Ali pays 10,000 out of 20,000.
      await paymentRepository.addPayment(
        dailyTransactionId: aliTransactionId,
        amount: 10000,
        paymentDate: DateTime.now(),
      );

      // Bilal pays the full 15,000.
      await paymentRepository.addPayment(
        dailyTransactionId: bilalTransactionId,
        amount: 15000,
        paymentDate: DateTime.now(),
      );

      // --------------------------------------------------
      // 5. Reload today's data
      // --------------------------------------------------

      await dailyController.loadDay(DateTime.now());

      // --------------------------------------------------
      // 6. Calculate summary
      // --------------------------------------------------

      final summary = await dailyController.getDailySummary();

      // --------------------------------------------------
      // Expected result
      //
      // Ali:
      // Sent       = 20,000
      // Received   = 10,000
      // Remaining  = 10,000
      //
      // Bilal:
      // Sent       = 15,000
      // Received   = 15,000
      // Remaining  = 0
      //
      // TOTAL:
      // Sent       = 35,000
      // Received   = 25,000
      // Remaining  = 10,000
      // Completed  = 1
      // Pending    = 1
      // --------------------------------------------------

      expect(summary.totalLoadSent, 35000);

      expect(summary.totalReceived, 25000);

      expect(summary.totalRemaining, 10000);

      expect(summary.completedCustomers, 1);

      expect(summary.pendingCustomers, 1);
    },
  );
}
