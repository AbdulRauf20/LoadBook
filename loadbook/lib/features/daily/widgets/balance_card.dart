import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final int openingBalance;
  final int closingBalance;

  const BalanceCard({
    super.key,
    required this.openingBalance,
    required this.closingBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Opening Balance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Rs. $openingBalance'),
              ],
            ),

            const Divider(height: 24),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Closing Balance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Rs. $closingBalance'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
