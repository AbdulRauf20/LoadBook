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

  int totalReceived = 0;

  bool isLoading = false;

  Future<void> loadCustomer(int customerId) async {
    isLoading = true;
    notifyListeners();

    customer = await customerRepository.getCustomerById(customerId);

    transactions = await transactionRepository.getTransactionsForCustomer(
      customerId,
    );

    totalReceived = await paymentRepository.getTotalReceivedForCustomer(
      customerId,
    );

    isLoading = false;
    notifyListeners();
  }

  int get totalLoadSent =>
      transactions.fold(0, (sum, transaction) => sum + transaction.loadSent);

  int get remaining => totalLoadSent - totalReceived;
}
