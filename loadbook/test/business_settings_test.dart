import 'package:flutter_test/flutter_test.dart';

import 'package:loadbook/data/local/database.dart';
import 'package:loadbook/data/repositories/business_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadBookDatabase database;
  late BusinessSettingsRepository repository;

  setUp(() {
    database = LoadBookDatabase.test();
    repository = BusinessSettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Creates business settings and stores available balance', () async {
    await repository.setAvailableBalance(100000);

    final balance = await repository.getAvailableBalance();

    expect(balance, 100000);
  });

  test('Increases available balance correctly', () async {
    await repository.setAvailableBalance(100000);

    await repository.increaseBalance(10000);

    final balance = await repository.getAvailableBalance();

    expect(balance, 110000);
  });

  test('Decreases available balance correctly', () async {
    await repository.setAvailableBalance(100000);

    await repository.decreaseBalance(20000);

    final balance = await repository.getAvailableBalance();

    expect(balance, 80000);
  });

  test('Handles multiple balance changes correctly', () async {
    await repository.setAvailableBalance(100000);

    // Load sent: -20,000
    await repository.decreaseBalance(20000);

    // Payment received: +10,000
    await repository.increaseBalance(10000);

    // Another load sent: -15,000
    await repository.decreaseBalance(15000);

    // Expected:
    //
    // 100,000
    // - 20,000
    // + 10,000
    // - 15,000
    // = 75,000

    final balance = await repository.getAvailableBalance();

    expect(balance, 75000);
  });

  test('Returns zero when no business settings exist', () async {
    final balance = await repository.getAvailableBalance();

    expect(balance, 0);
  });
}
