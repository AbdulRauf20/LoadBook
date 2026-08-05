import 'package:flutter/foundation.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class DailyController extends ChangeNotifier {
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;
  final PaymentRepository paymentRepository;

  DailyController(LoadBookDatabase database)
    : customerRepository = CustomerRepository(database),
      transactionRepository = TransactionRepository(database),
      paymentRepository = PaymentRepository(database);

  DateTime selectedDate = DateTime.now();

  List<Customer> customers = [];
  List<DailyTransaction> transactions = [];

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadDay(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      customers = await customerRepository.getActiveCustomers();

      transactions = await transactionRepository.getTransactionsForDate(
        selectedDate,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DailyTransaction> getOrCreateTransaction(int customerId) async {
    final existing = await transactionRepository.getTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    if (existing != null) {
      return existing;
    }

    final id = await transactionRepository.createDailyTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    final transaction = await transactionRepository.getTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    if (transaction == null) {
      throw Exception('Failed to create daily transaction.');
    }

    return transaction;
  }

  Future<void> setLoadAmount({
    required int customerId,
    required int amount,
  }) async {
    final transaction = await getOrCreateTransaction(customerId);

    await transactionRepository.updateLoadSent(
      transactionId: transaction.id,
      loadAmount: amount,
    );

    await loadDay(selectedDate);
  }

  Future<void> addPayment({
    required int customerId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    final transaction = await getOrCreateTransaction(customerId);

    await paymentRepository.addPayment(
      dailyTransactionId: transaction.id,
      amount: amount,
      paymentDate: DateTime.now(),
    );

    await loadDay(selectedDate);
  }

  Future<int> getAmountReceived(int transactionId) {
    return paymentRepository.getTotalReceived(transactionId);
  }

  Future<int> getRemainingAmount(DailyTransaction transaction) async {
    final received = await getAmountReceived(transaction.id);

    final remaining = transaction.loadSent - received;

    return remaining < 0 ? 0 : remaining;
  }

  Future<void> nextDay() async {
    await loadDay(selectedDate.add(const Duration(days: 1)));
  }

  Future<void> previousDay() async {
    await loadDay(selectedDate.subtract(const Duration(days: 1)));
  }
}
