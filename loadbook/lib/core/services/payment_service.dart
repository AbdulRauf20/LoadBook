import '../../data/repositories/business_settings_repository.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentService {
  final PaymentRepository paymentRepository;
  final BusinessSettingsRepository businessSettingsRepository;

  PaymentService({
    required this.paymentRepository,
    required this.businessSettingsRepository,
  });

  /// Records a payment received from a customer
  /// and increases the available balance.
  Future<int> recordPayment({
    required int dailyTransactionId,
    required int amount,
    required DateTime paymentDate,
  }) async {
    if (amount < 0) {
      throw ArgumentError(
        'Payment amount cannot be negative.',
      );
    }

    if (amount == 0) {
      throw ArgumentError(
        'Payment amount must be greater than zero.',
      );
    }

    final paymentId =
        await paymentRepository.addPayment(
      dailyTransactionId: dailyTransactionId,
      amount: amount,
      paymentDate: paymentDate,
    );

    await businessSettingsRepository.increaseBalance(
      amount,
    );

    return paymentId;
  }
}