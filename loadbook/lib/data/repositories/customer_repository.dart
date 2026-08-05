import 'package:drift/drift.dart';

import '../local/database.dart';

class CustomerRepository {
  final LoadBookDatabase database;

  CustomerRepository(this.database);

  Future<int> addCustomer({
    required String name,
    required String phoneNumber,
    int monthlySales = 0,
  }) {
    return database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            name: name,
            phoneNumber: phoneNumber,
            monthlySales: Value(monthlySales),
          ),
        );
  }

  Future<List<Customer>> getActiveCustomers() {
    return (database.select(database.customers)
          ..where((customer) => customer.isActive.equals(true))
          ..orderBy([(customer) => OrderingTerm(expression: customer.name)]))
        .get();
  }

  Future<Customer?> getCustomerById(int id) {
    return (database.select(
      database.customers,
    )..where((customer) => customer.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateCustomer({
    required int id,
    required String name,
    required String phoneNumber,
    required int monthlySales,
  }) {
    return (database.update(database.customers)
          ..where((customer) => customer.id.equals(id)))
        .write(
          CustomersCompanion(
            name: Value(name),
            phoneNumber: Value(phoneNumber),
            monthlySales: Value(monthlySales),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<bool> deactivateCustomer(int id) {
    return (database.update(database.customers)
          ..where((customer) => customer.id.equals(id)))
        .write(
          CustomersCompanion(
            isActive: const Value(false),
            updatedAt: Value.absent(),
          ),
        )
        .then((rows) => rows > 0);
  }
}
