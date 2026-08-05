import '../../data/repositories/business_settings_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionService {
  final TransactionRepository transactionRepository;
  final BusinessSettingsRepository businessSettingsRepository;

  TransactionService({
    required this.transactionRepository,
    required this.businessSettingsRepository,
  });

  /// Creates a daily transaction and records the load sent.
  ///
  /// The available balance is reduced by the load amount.
  Future<int> createTransactionWithLoad({
    required int customerId,
    required DateTime date,
    required int loadAmount,
  }) async {
    if (loadAmount < 0) {
      throw ArgumentError('Load amount cannot be negative.');
    }

    final transactionId = await transactionRepository.createDailyTransaction(
      customerId: customerId,
      date: date,
    );

    if (loadAmount > 0) {
      await transactionRepository.updateLoadSent(
        transactionId: transactionId,
        loadAmount: loadAmount,
      );

      await businessSettingsRepository.decreaseBalance(loadAmount);
    }

    return transactionId;
  }

  /// Updates an existing transaction's load amount.
  ///
  /// Only the difference between the old and new
  /// load amount affects the available balance.
  Future<bool> updateLoad({
    required int transactionId,
    required int oldLoadAmount,
    required int newLoadAmount,
  }) async {
    if (newLoadAmount < 0) {
      throw ArgumentError('Load amount cannot be negative.');
    }

    final difference = newLoadAmount - oldLoadAmount;

    final updated = await transactionRepository.updateLoadSent(
      transactionId: transactionId,
      loadAmount: newLoadAmount,
    );

    if (!updated) {
      return false;
    }

    if (difference > 0) {
      await businessSettingsRepository.decreaseBalance(difference);
    } else if (difference < 0) {
      await businessSettingsRepository.increaseBalance(difference.abs());
    }

    return true;
  }
}
