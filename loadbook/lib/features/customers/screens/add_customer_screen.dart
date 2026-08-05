import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_form.dart';

class AddCustomerScreen extends StatefulWidget {
  final LoadBookDatabase database;

  const AddCustomerScreen({super.key, required this.database});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: CustomerForm(
          onSave:
              ({required name, required phoneNumber, required monthlySales}) {
                return controller.addCustomer(
                  name: name,
                  phoneNumber: phoneNumber,
                  monthlySales: monthlySales,
                );
              },
        ),
      ),
    );
  }
}
