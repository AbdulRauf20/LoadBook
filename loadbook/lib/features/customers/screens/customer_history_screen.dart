import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    final remaining = controller.remaining < 0 ? 0 : controller.remaining;

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      customer.phoneNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _StatCard(
                  label: 'Load Sent',
                  amount: controller.totalLoadSent,
                  color: const Color(0xFF37474F),
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Received',
                  amount: controller.totalReceived,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Remaining',
                  amount: remaining,
                  color: remaining > 0
                      ? const Color(0xFFC62828)
                      : const Color(0xFF2E7D32),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: controller.transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: controller.transactions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final transaction = controller.transactions[index];
                        final received = controller.receivedFor(transaction.id);
                        final txRemaining = controller.remainingFor(transaction);

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(transaction.transactionDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _MiniStat(
                                      label: 'Sent',
                                      amount: transaction.loadSent,
                                    ),
                                    _MiniStat(
                                      label: 'Received',
                                      amount: received,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                    _MiniStat(
                                      label: 'Remaining',
                                      amount: txRemaining,
                                      color: txRemaining > 0
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Rs. $amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int amount;
  final Color? color;

  const _MiniStat({required this.label, required this.amount, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          'Rs. $amount',
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
