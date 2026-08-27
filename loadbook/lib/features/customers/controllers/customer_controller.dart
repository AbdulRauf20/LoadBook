import 'package:flutter/foundation.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class CustomerController extends ChangeNotifier {
  final CustomerRepository repository;
  final TransactionRepository transactionRepository;
  final PaymentRepository paymentRepository;

  CustomerController(LoadBookDatabase database)
    : repository = CustomerRepository(database),
      transactionRepository = TransactionRepository(database),
      paymentRepository = PaymentRepository(database);

  List<Customer> customers = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCustomers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      customers = await repository.getActiveCustomers();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer({
    required String name,
    required String phoneNumber,
    int monthlySales = 0,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage = 'Customer name is required.';
      notifyListeners();
      return false;
    }

    if (phoneNumber.trim().isEmpty) {
      errorMessage = 'Phone number is required.';
      notifyListeners();
      return false;
    }

    try {
      await repository.addCustomer(
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        monthlySales: monthlySales,
      );

      await loadCustomers();

      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sum of load sent for this customer within the current calendar month.
  Future<int> currentMonthLoad(int id) async {
    final now = DateTime.now();

    final transactions = await transactionRepository.getTransactionsForCustomer(
      id,
    );

    return transactions
        .where(
          (t) =>
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month,
        )
        .fold<int>(0, (sum, t) => sum + t.loadSent);
  }

  /// Removes all transactional/test data for a customer while keeping the
  /// customer account (name, phone) intact. Also clears manual monthly sales.
  Future<bool> resetCustomerData(int id) async {
    try {
      final transactions = await transactionRepository
          .getTransactionsForCustomer(id);

      for (final transaction in transactions) {
        await paymentRepository.deletePaymentsForTransaction(transaction.id);
      }

      await transactionRepository.deleteTransactionsForCustomer(id);

      final customer = await repository.getCustomerById(id);

      if (customer != null) {
        await repository.updateCustomer(
          id: id,
          name: customer.name,
          phoneNumber: customer.phoneNumber,
          monthlySales: 0,
        );
      }

      await loadCustomers();

      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateCustomer(int id) async {
    try {
      final success = await repository.deactivateCustomer(id);

      if (success) {
        await loadCustomers();
      }

      return success;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer({
    required int id,
    required String name,
    required String phoneNumber,
    required int monthlySales,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage = 'Customer name is required.';
      notifyListeners();
      return false;
    }

    if (phoneNumber.trim().isEmpty) {
      errorMessage = 'Phone number is required.';
      notifyListeners();
      return false;
    }

    try {
      final success = await repository.updateCustomer(
        id: id,
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        monthlySales: monthlySales,
      );

      if (success) {
        await loadCustomers();
      }

      return success;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
