import 'package:flutter/material.dart';

import '../../../core/services/whatsapp_service.dart';
import '../../../models/customer_daily_data.dart';
import '../controllers/daily_controller.dart';

class RemainingClientsBar extends StatelessWidget {
  final DailyController controller;

  const RemainingClientsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final remaining = controller.remainingCustomers;
    final count = remaining.length;
    final allClear = count == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: allClear
              ? const Color(0xFFEFF5EF)
              : const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: allClear
                ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                : const Color(0xFFEF6C00).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              allClear ? Icons.verified : Icons.notifications_active_outlined,
              color: allClear
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFEF6C00),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                allClear ? 'All Clear ✓' : 'Remaining Clients: $count',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.icon(
              onPressed: allClear
                  ? null
                  : () => _showRemainingSheet(context, remaining),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Remind'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemainingSheet(
    BuildContext context,
    List<CustomerDailyData> remaining,
  ) {
    final whatsappService = WhatsAppService();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Remaining Customers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const Text(
                  'Tap Send to open WhatsApp for each customer. '
                  'Messages open one at a time.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: remaining.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final data = remaining[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          data.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Remaining: Rs. ${data.remaining}',
                          style: const TextStyle(color: Color(0xFFC62828)),
                        ),
                        trailing: FilledButton.icon(
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('Send'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(
                              sheetContext,
                            );
                            try {
                              await whatsappService.sendReminder(
                                phone: data.phoneNumber,
                                customerName: data.customerName,
                                remainingBalance: data.remaining,
                              );
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open WhatsApp.'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
