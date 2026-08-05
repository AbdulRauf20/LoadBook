import 'package:flutter/material.dart';

import '../../../models/daily_summary.dart';

class DailySummaryWidget extends StatelessWidget {
  final DailySummary summary;

  const DailySummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _SummaryRow(label: 'Total Load Sent', value: summary.totalLoadSent),

            _SummaryRow(label: 'Total Received', value: summary.totalReceived),

            _SummaryRow(
              label: 'Total Remaining',
              value: summary.totalRemaining,
            ),

            const Divider(height: 24),

            _RowValue(
              label: 'Completed',
              value: summary.completedCustomers.toString(),
            ),

            _RowValue(
              label: 'Pending',
              value: summary.pendingCustomers.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            'Rs. $value',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  final String label;
  final String value;

  const _RowValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
