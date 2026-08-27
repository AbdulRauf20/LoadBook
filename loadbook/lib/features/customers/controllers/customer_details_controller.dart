import 'package:flutter/foundation.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class CustomerDetailsController extends ChangeNotifier {
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;
  final PaymentRepository paymentRepository;

  CustomerDetailsController(LoadBookDatabase database)
    : customerRepository = CustomerRepository(database),
      transactionRepository = TransactionRepository(database),
      paymentRepository = PaymentRepository(database);

  Customer? customer;

  List<DailyTransaction> transactions = [];

  /// Received amount per daily transaction id.
  Map<int, int> receivedByTransaction = {};

  int totalReceived = 0;

  bool isLoading = false;

  Future<void> loadCustomer(int customerId) async {
    isLoading = true;
    notifyListeners();

    customer = await customerRepository.getCustomerById(customerId);

    transactions = await transactionRepository.getTransactionsForCustomer(
      customerId,
    );

    final received = <int, int>{};
    var total = 0;

    for (final transaction in transactions) {
      final amount = await paymentRepository.getTotalReceived(transaction.id);
      received[transaction.id] = amount;
      total += amount;
    }

    receivedByTransaction = received;
    totalReceived = total;

    isLoading = false;
    notifyListeners();
  }

  int receivedFor(int transactionId) => receivedByTransaction[transactionId] ?? 0;

  int remainingFor(DailyTransaction transaction) {
    final value = transaction.loadSent - receivedFor(transaction.id);
    return value < 0 ? 0 : value;
  }

  int get totalLoadSent =>
      transactions.fold(0, (sum, transaction) => sum + transaction.loadSent);

  int get remaining => totalLoadSent - totalReceived;
}
