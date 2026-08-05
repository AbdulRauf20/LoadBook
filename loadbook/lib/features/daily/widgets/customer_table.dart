import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../controllers/daily_controller.dart';
import 'customer_row.dart';

class CustomerTable extends StatelessWidget {
  final DailyController controller;

  const CustomerTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(child: Text(controller.errorMessage!));
    }

    if (controller.customers.isEmpty) {
      return const Center(
        child: Text('No customers added yet.', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.customers.length,
      itemBuilder: (context, index) {
        final customer = controller.customers[index];

        final matchingTransactions = controller.transactions.where(
          (transaction) => transaction.customerId == customer.id,
        );

        final DailyTransaction? transaction = matchingTransactions.isEmpty
            ? null
            : matchingTransactions.first;

        return CustomerRow(
          customer: customer,
          transaction: transaction,
          controller: controller,
        );
      },
    );
  }
}
