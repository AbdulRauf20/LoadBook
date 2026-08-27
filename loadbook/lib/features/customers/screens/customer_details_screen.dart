import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_form.dart';
import 'customer_history_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final LoadBookDatabase database;
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.database,
    required this.customer,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late final CustomerController controller;

  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    controller = CustomerController(widget.database);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> _updateCustomer({
    required String name,
    required String phoneNumber,
    required int monthlySales,
  }) async {
    return controller.repository.updateCustomer(
      id: widget.customer.id,
      name: name,
      phoneNumber: phoneNumber,
      monthlySales: monthlySales,
    );
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerHistoryScreen(
          database: widget.database,
          customerId: widget.customer.id,
        ),
      ),
    );
  }

  Future<void> _resetCustomerData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset customer data?'),
        content: const Text(
          'This will remove this customer\'s transaction and payment data '
          'and clear monthly sales. The customer account (name and phone) '
          'will be kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isResetting = true);

    final success = await controller.resetCustomerData(widget.customer.id);

    if (!mounted) return;

    setState(() => _isResetting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer data reset.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Could not reset data.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          widget.customer.phoneNumber,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<int>(
                      future: controller.currentMonthLoad(widget.customer.id),
                      builder: (context, snapshot) {
                        final value = snapshot.data ?? 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5EF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insights_outlined,
                                size: 16,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'This month\'s load (actual): Rs. $value',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Edit Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            CustomerForm(
              initialName: widget.customer.name,
              initialPhoneNumber: widget.customer.phoneNumber,
              initialMonthlySales: widget.customer.monthlySales,
              onSave: _updateCustomer,
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: _isResetting ? null : _openHistory,
              icon: const Icon(Icons.history),
              label: const Text('View Customer History'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isResetting ? null : _resetCustomerData,
              icon: _isResetting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt, color: Colors.red),
              label: const Text(
                'Reset Customer Data',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
