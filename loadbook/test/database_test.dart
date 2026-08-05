import 'package:flutter_test/flutter_test.dart';
import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/customer_repository.dart';
import 'package:loadbook/data/repositories/payment_repository.dart';
import 'package:loadbook/data/repositories/transaction_repository.dart';

void main() {
  late LoadBookDatabase database;
  late CustomerRepository customerRepository;
  late TransactionRepository transactionRepository;
  late PaymentRepository paymentRepository;

  setUp(() {
    database = LoadBookDatabase.test();
    customerRepository = CustomerRepository(database);
    transactionRepository = TransactionRepository(database);
    paymentRepository = PaymentRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('LoadBook complete daily transaction workflow', () async {
    // --------------------------------------------------
    // 1. ADD CUSTOMERS
    // --------------------------------------------------

    final aliId = await customerRepository.addCustomer(
      name: 'Ali Mobile',
      phoneNumber: '03001234567',
      monthlySales: 500000,
    );

    final bilalId = await customerRepository.addCustomer(
      name: 'Bilal Mobile',
      phoneNumber: '03007654321',
      monthlySales: 350000,
    );

    expect(aliId, greaterThan(0));
    expect(bilalId, greaterThan(0));

    // --------------------------------------------------
    // 2. VERIFY CUSTOMERS
    // --------------------------------------------------

    final customers = await customerRepository.getActiveCustomers();

    expect(customers.length, 2);

    // --------------------------------------------------
    // 3. CREATE TODAY'S TRANSACTIONS
    // --------------------------------------------------

    final today = DateTime(2026, 8, 5);

    final aliTransactionId = await transactionRepository.createDailyTransaction(
      customerId: aliId,
      date: today,
    );

    final bilalTransactionId = await transactionRepository
        .createDailyTransaction(customerId: bilalId, date: today);

    expect(aliTransactionId, greaterThan(0));
    expect(bilalTransactionId, greaterThan(0));

    // --------------------------------------------------
    // 4. SET LOAD AMOUNTS
    // --------------------------------------------------

    await transactionRepository.updateLoadSent(
      transactionId: aliTransactionId,
      loadAmount: 20000,
    );

    await transactionRepository.updateLoadSent(
      transactionId: bilalTransactionId,
      loadAmount: 15000,
    );

    // --------------------------------------------------
    // 5. ADD PAYMENTS
    // --------------------------------------------------

    // Ali pays 5,000 first.
    await paymentRepository.addPayment(
      dailyTransactionId: aliTransactionId,
      amount: 5000,
      paymentDate: today,
    );

    // Ali pays another 5,000 later.
    await paymentRepository.addPayment(
      dailyTransactionId: aliTransactionId,
      amount: 5000,
      paymentDate: today,
    );

    // Bilal pays the full amount.
    await paymentRepository.addPayment(
      dailyTransactionId: bilalTransactionId,
      amount: 15000,
      paymentDate: today,
    );

    // --------------------------------------------------
    // 6. CALCULATE TOTAL RECEIVED
    // --------------------------------------------------

    final aliReceived = await paymentRepository.getTotalReceived(
      aliTransactionId,
    );

    final bilalReceived = await paymentRepository.getTotalReceived(
      bilalTransactionId,
    );

    expect(aliReceived, 10000);
    expect(bilalReceived, 15000);

    // --------------------------------------------------
    // 7. CALCULATE REMAINING
    // --------------------------------------------------

    const aliLoad = 20000;
    const bilalLoad = 15000;

    final aliRemaining = aliLoad - aliReceived;
    final bilalRemaining = bilalLoad - bilalReceived;

    expect(aliRemaining, 10000);
    expect(bilalRemaining, 0);

    // --------------------------------------------------
    // 8. VERIFY TODAY'S TRANSACTIONS
    // --------------------------------------------------

    final transactions = await transactionRepository.getTransactionsForDate(
      today,
    );

    expect(transactions.length, 2);

    // --------------------------------------------------
    // 9. PRINT RESULT
    // --------------------------------------------------

    print('----------------------------------------');
    print('LOADBOOK DATABASE TEST');
    print('----------------------------------------');

    print('Ali Mobile');
    print('Load Sent:       Rs. $aliLoad');
    print('Amount Received: Rs. $aliReceived');
    print('Remaining:       Rs. $aliRemaining');
    print('');

    print('Bilal Mobile');
    print('Load Sent:       Rs. $bilalLoad');
    print('Amount Received: Rs. $bilalReceived');
    print('Remaining:       Rs. $bilalRemaining');
    print('');

    print('Database workflow successful!');
    print('----------------------------------------');
  });
}
