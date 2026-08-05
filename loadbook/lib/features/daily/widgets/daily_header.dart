import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const DailyHeader({
    super.key,
    required this.date,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: onPreviousDay,
            icon: const Icon(Icons.arrow_back),
          ),

          Expanded(
            child: Column(
              children: [
                const Text(
                  'Daily Load',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onNextDay,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
