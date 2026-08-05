import 'package:flutter/material.dart';

import '../controllers/daily_controller.dart';

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

        final transaction = controller.transactions
            .where((transaction) => transaction.customerId == customer.id)
            .cast<dynamic>()
            .firstOrNull;

        return _CustomerRow(
          customer: customer,
          transaction: transaction,
          controller: controller,
        );
      },
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final dynamic customer;
  final dynamic transaction;
  final DailyController controller;

  const _CustomerRow({
    required this.customer,
    required this.transaction,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final loadSent = transaction?.loadSent ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_box_outline_blank, size: 28),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.phoneNumber,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                const Text('Load', style: TextStyle(fontSize: 12)),
                Text(
                  'Rs. $loadSent',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(width: 8),

            PopupMenuButton<int>(
              onSelected: (amount) {
                controller.setLoadAmount(
                  customerId: customer.id,
                  amount: amount,
                );
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 5000, child: Text('5,000')),
                PopupMenuItem(value: 10000, child: Text('10,000')),
                PopupMenuItem(value: 15000, child: Text('15,000')),
                PopupMenuItem(value: 20000, child: Text('20,000')),
              ],
              child: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
