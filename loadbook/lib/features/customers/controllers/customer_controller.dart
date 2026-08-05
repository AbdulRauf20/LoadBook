import 'package:flutter/foundation.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  final CustomerRepository repository;

  CustomerController(LoadBookDatabase database)
    : repository = CustomerRepository(database);

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
}
