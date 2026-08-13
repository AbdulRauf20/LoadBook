import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_form.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: CustomerForm(
          initialName: widget.customer.name,
          initialPhoneNumber: widget.customer.phoneNumber,
          initialMonthlySales: widget.customer.monthlySales,
          onSave: _updateCustomer, initialLoadSent: 0,
        ),
      ),
    );
  }
}
