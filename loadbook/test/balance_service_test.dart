import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/business_settings_repository.dart';
import 'package:loadbook/core/services/balance_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LoadBookDatabase database;
  late BusinessSettingsRepository settingsRepository;
  late BalanceService balanceService;

  setUp(() {
    database = LoadBookDatabase.test();

    settingsRepository = BusinessSettingsRepository(database);

    balanceService = BalanceService(settingsRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('Load sent decreases available balance', () async {
    await settingsRepository.setAvailableBalance(100000);

    await balanceService.recordLoadSent(20000);

    final balance = await balanceService.getCurrentBalance();

    expect(balance, 80000);
  });

  test('Payment received increases available balance', () async {
    await settingsRepository.setAvailableBalance(80000);

    await balanceService.recordPaymentReceived(10000);

    final balance = await balanceService.getCurrentBalance();

    expect(balance, 90000);
  });

  test(
    'Complete LoadBook money workflow calculates balance correctly',
    () async {
      // Starting balance.
      await settingsRepository.setAvailableBalance(100000);

      // Father sends Rs. 30,000 load.
      await balanceService.recordLoadSent(30000);

      // Customer pays Rs. 10,000.
      await balanceService.recordPaymentReceived(10000);

      // Another customer pays Rs. 5,000.
      await balanceService.recordPaymentReceived(5000);

      // Another Rs. 20,000 load is sent.
      await balanceService.recordLoadSent(20000);

      // 100,000
      // - 30,000
      // + 10,000
      // +  5,000
      // - 20,000
      // = 65,000

      final balance = await balanceService.getCurrentBalance();

      expect(balance, 65000);
    },
  );

  test('Zero load does not change balance', () async {
    await settingsRepository.setAvailableBalance(50000);

    await balanceService.recordLoadSent(0);

    final balance = await balanceService.getCurrentBalance();

    expect(balance, 50000);
  });

  test('Zero payment does not change balance', () async {
    await settingsRepository.setAvailableBalance(50000);

    await balanceService.recordPaymentReceived(0);

    final balance = await balanceService.getCurrentBalance();

    expect(balance, 50000);
  });

  test('Negative load amount is rejected', () async {
    await settingsRepository.setAvailableBalance(50000);

    expect(() => balanceService.recordLoadSent(-1000), throwsArgumentError);
  });

  test('Negative payment amount is rejected', () async {
    await settingsRepository.setAvailableBalance(50000);

    expect(
      () => balanceService.recordPaymentReceived(-1000),
      throwsArgumentError,
    );
  });
}
