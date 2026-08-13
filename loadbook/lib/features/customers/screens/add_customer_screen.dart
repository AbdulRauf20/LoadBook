import 'package:flutter/material.dart';
import 'package:loadbook/features/daily/screens/daily_screen.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DailyScreen(database: widget.database),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text("Add Customer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: CustomerForm(
          onSave:
              ({
                required name,
                required phoneNumber,
                required monthlySales,
              }) async {
                final success = await controller.addCustomer(
                  name: name,
                  phoneNumber: phoneNumber,
                  monthlySales: monthlySales,
                );

                if (!mounted) return success;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer added successfully'),
                    ),
                  );

                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.errorMessage ?? 'Unable to add customer.',
                      ),
                    ),
                  );
                }

                return success;
              }, initialLoadSent: 0,
        ),
      ),
    );
  }
}
