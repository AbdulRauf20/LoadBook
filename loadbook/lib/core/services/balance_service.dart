import '../../data/repositories/business_settings_repository.dart';

class BalanceService {
  final BusinessSettingsRepository businessSettingsRepository;

  BalanceService(this.businessSettingsRepository);

  Future<int> getCurrentBalance() {
    return businessSettingsRepository.getAvailableBalance();
  }

  Future<void> recordLoadSent(int amount) async {
    if (amount < 0) {
      throw ArgumentError('Load amount cannot be negative.');
    }

    if (amount == 0) {
      return;
    }

    await businessSettingsRepository.decreaseBalance(amount);
  }

  Future<void> recordPaymentReceived(int amount) async {
    if (amount < 0) {
      throw ArgumentError('Payment amount cannot be negative.');
    }

    if (amount == 0) {
      return;
    }

    await businessSettingsRepository.increaseBalance(amount);
  }
}
