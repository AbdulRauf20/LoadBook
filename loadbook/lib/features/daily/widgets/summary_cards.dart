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
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  _SummaryCard(
                    title: 'Sent',
                    amount: summary.totalLoadSent,
                    color: const Color(0xFF37474F),
                  ),
                  const SizedBox(width: 10),
                  _SummaryCard(
                    title: 'Received',
                    amount: summary.totalReceived,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 10),
                  _SummaryCard(
                    title: 'Remaining',
                    amount: summary.totalRemaining,
                    color: summary.totalRemaining > 0
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CountChip(
                    icon: Icons.check_circle,
                    color: const Color(0xFF2E7D32),
                    label: 'Completed',
                    count: summary.completedCustomers,
                  ),
                  const SizedBox(width: 10),
                  _CountChip(
                    icon: Icons.pending_actions,
                    color: const Color(0xFFEF6C00),
                    label: 'Pending',
                    count: summary.pendingCustomers,
                  ),
                ],
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
  final Color color;

  const _SummaryCard({
    required this.title,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rs. $amount',
                  style: TextStyle(
                    fontSize: 18,
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

class _CountChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _CountChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
