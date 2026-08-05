import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/core/services/transaction_service.dart';
import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/business_settings_repository.dart';
import 'package:loadbook/data/repositories/customer_repository.dart';
import 'package:loadbook/data/repositories/transaction_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadBookDatabase database;
  late CustomerRepository customerRepository;
  late TransactionRepository transactionRepository;
  late BusinessSettingsRepository settingsRepository;
  late TransactionService transactionService;

  setUp(() {
    database = LoadBookDatabase.test();

    customerRepository = CustomerRepository(database);

    transactionRepository = TransactionRepository(database);

    settingsRepository = BusinessSettingsRepository(database);

    transactionService = TransactionService(
      transactionRepository: transactionRepository,
      businessSettingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('Creating a transaction with load decreases balance', () async {
    await settingsRepository.setAvailableBalance(100000);

    final customerId = await customerRepository.addCustomer(
      name: 'Ali Mobile',
      phoneNumber: '03001234567',
    );

    final transactionId = await transactionService.createTransactionWithLoad(
      customerId: customerId,
      date: DateTime(2026, 8, 5),
      loadAmount: 20000,
    );

    expect(transactionId, greaterThan(0));

    final balance = await settingsRepository.getAvailableBalance();

    expect(balance, 80000);
  });

  test('Updating load only changes balance by the difference', () async {
    await settingsRepository.setAvailableBalance(100000);

    final customerId = await customerRepository.addCustomer(
      name: 'Bilal Mobile',
      phoneNumber: '03007654321',
    );

    final transactionId = await transactionService.createTransactionWithLoad(
      customerId: customerId,
      date: DateTime(2026, 8, 5),
      loadAmount: 10000,
    );

    expect(await settingsRepository.getAvailableBalance(), 90000);

    await transactionService.updateLoad(
      transactionId: transactionId,
      oldLoadAmount: 10000,
      newLoadAmount: 15000,
    );

    expect(await settingsRepository.getAvailableBalance(), 85000);
  });

  test('Reducing load returns the difference to balance', () async {
    await settingsRepository.setAvailableBalance(100000);

    final customerId = await customerRepository.addCustomer(
      name: 'Ahmed Mobile',
      phoneNumber: '03001112222',
    );

    final transactionId = await transactionService.createTransactionWithLoad(
      customerId: customerId,
      date: DateTime(2026, 8, 5),
      loadAmount: 20000,
    );

    expect(await settingsRepository.getAvailableBalance(), 80000);

    await transactionService.updateLoad(
      transactionId: transactionId,
      oldLoadAmount: 20000,
      newLoadAmount: 12000,
    );

    expect(await settingsRepository.getAvailableBalance(), 88000);
  });
}
