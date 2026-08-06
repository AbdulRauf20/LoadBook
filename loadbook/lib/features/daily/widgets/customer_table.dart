import 'package:flutter/material.dart';
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

    if (controller.customerDailyData.isEmpty) {
      return const Center(
        child: Text('No customers added yet.', style: TextStyle(fontSize: 18)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadDay(controller.selectedDate),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: controller.customerDailyData.length,
        itemBuilder: (context, index) {
          return CustomerRow(
            customerData: controller.customerDailyData[index],
            controller: controller,
          );
        },
      ),
    );
  }
}
