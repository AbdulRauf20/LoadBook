import 'package:flutter/material.dart';

import '../controllers/daily_controller.dart';

class SummaryCards extends StatelessWidget {
  final DailyController controller;

  const SummaryCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _calculateTotals(),
      builder: (context, snapshot) {
        final totalLoad = snapshot.data?[0] ?? 0;
        final totalReceived = snapshot.data?[1] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(title: 'Today\'s Sell', amount: totalLoad),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SummaryCard(title: 'Received', amount: totalReceived),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<int>> _calculateTotals() async {
    int totalLoad = 0;
    int totalReceived = 0;

    for (final transaction in controller.transactions) {
      totalLoad += transaction.loadSent;

      totalReceived += await controller.getAmountReceived(transaction.id);
    }

    return [totalLoad, totalReceived];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int amount;

  const _SummaryCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              'Rs. ${amount.toString()}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
