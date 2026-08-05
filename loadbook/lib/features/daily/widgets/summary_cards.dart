import 'package:flutter/material.dart';

import '../controllers/daily_controller.dart';

class SummaryCards extends StatelessWidget {
  final DailyController controller;

  const SummaryCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.getDailySummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Today\'s Sell',
                  amount: summary.totalLoadSent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SummaryCard(
                  title: 'Received',
                  amount: summary.totalReceived,
                ),
              ),
            ],
          ),
        );
      },
    );
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
              'Rs. $amount',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
