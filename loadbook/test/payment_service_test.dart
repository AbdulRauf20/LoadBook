import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/core/services/payment_service.dart';
import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/business_settings_repository.dart';
import 'package:loadbook/data/repositories/payment_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadBookDatabase database;
  late PaymentRepository paymentRepository;
  late BusinessSettingsRepository settingsRepository;
  late PaymentService paymentService;

  setUp(() {
    database = LoadBookDatabase.test();

    paymentRepository = PaymentRepository(database);

    settingsRepository = BusinessSettingsRepository(database);

    paymentService = PaymentService(
      paymentRepository: paymentRepository,
      businessSettingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('Recording a payment increases available balance', () async {
    await settingsRepository.setAvailableBalance(80000);

    final paymentId = await paymentService.recordPayment(
      dailyTransactionId: 1,
      amount: 10000,
      paymentDate: DateTime(2026, 8, 5),
    );

    expect(paymentId, greaterThan(0));

    final balance = await settingsRepository.getAvailableBalance();

    expect(balance, 90000);
  });

  test('Multiple payments increase balance correctly', () async {
    await settingsRepository.setAvailableBalance(50000);

    await paymentService.recordPayment(
      dailyTransactionId: 1,
      amount: 10000,
      paymentDate: DateTime(2026, 8, 5),
    );

    await paymentService.recordPayment(
      dailyTransactionId: 1,
      amount: 5000,
      paymentDate: DateTime(2026, 8, 5),
    );

    await paymentService.recordPayment(
      dailyTransactionId: 1,
      amount: 15000,
      paymentDate: DateTime(2026, 8, 5),
    );

    final balance = await settingsRepository.getAvailableBalance();

    expect(balance, 80000);
  });

  test('Zero payment is rejected', () async {
    await settingsRepository.setAvailableBalance(50000);

    expect(
      () => paymentService.recordPayment(
        dailyTransactionId: 1,
        amount: 0,
        paymentDate: DateTime(2026, 8, 5),
      ),
      throwsArgumentError,
    );
  });

  test('Negative payment is rejected', () async {
    await settingsRepository.setAvailableBalance(50000);

    expect(
      () => paymentService.recordPayment(
        dailyTransactionId: 1,
        amount: -5000,
        paymentDate: DateTime(2026, 8, 5),
      ),
      throwsArgumentError,
    );
  });
}
