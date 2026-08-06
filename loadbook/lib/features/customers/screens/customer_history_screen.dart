import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../controllers/customer_details_controller.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final LoadBookDatabase database;
  final int customerId;

  const CustomerHistoryScreen({
    super.key,
    required this.database,
    required this.customerId,
  });

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  late final CustomerDetailsController controller;

  @override
  void initState() {
    super.initState();

    controller = CustomerDetailsController(widget.database);

    controller.loadCustomer(widget.customerId);

    controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final customer = controller.customer;

    if (customer == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(customer.phoneNumber),
                subtitle: const Text('Phone Number'),
              ),
            ),

            Card(
              child: ListTile(
                title: Text('Rs. ${controller.totalLoadSent}'),
                subtitle: const Text('Total Load Sent'),
              ),
            ),

            Card(
              child: ListTile(
                title: Text('Rs. ${controller.totalReceived}'),
                subtitle: const Text('Total Received'),
              ),
            ),

            Card(
              child: ListTile(
                title: Text('Rs. ${controller.remaining}'),
                subtitle: const Text('Remaining Balance'),
              ),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transaction History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];

                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Rs. ${transaction.loadSent}'),
                    subtitle: Text(
                      transaction.transactionDate.toString().split(' ').first,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
