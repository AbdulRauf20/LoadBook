import 'package:flutter/material.dart';
import 'package:loadbook/core/services/whatsapp_service.dart';
import 'package:loadbook/features/customers/screens/customer_details_screen.dart';
import 'package:loadbook/models/customer_daily_data.dart';

import '../controllers/daily_controller.dart';

class CustomerRow extends StatefulWidget {
  final CustomerDailyData customerData;
  final DailyController controller;

  const CustomerRow({
    super.key,
    required this.customerData,
    required this.controller,
  });

  @override
  State<CustomerRow> createState() => _CustomerRowState();
}

class _CustomerRowState extends State<CustomerRow> {
  int received = 0;
  bool isLoading = false;

  final WhatsAppService whatsappService = WhatsAppService();

  @override
  void initState() {
    super.initState();
    _loadReceived();
  }

  @override
  void didUpdateWidget(covariant CustomerRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.customerData.transactionId !=
        widget.customerData.transactionId) {
      _loadReceived();
    }
  }

  Future<void> _loadReceived() async {
    final amount = await widget.controller.getAmountReceived(
      widget.customerData.transactionId,
    );

    if (mounted) {
      setState(() {
        received = amount;
      });
    }
  }

  int get loadSent => widget.customerData.loadSent;

  int get remaining {
    final value = loadSent - received;
    return value < 0 ? 0 : value;
  }

  bool get isDone => loadSent > 0 && remaining == 0;
  Future<void> _editLoadAmount() async {
    final controller = TextEditingController(text: loadSent.toString());

    final amount = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Load Sent'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            selectAllOnFocus: true,
            decoration: const InputDecoration(
              labelText: 'Load Sent',
              prefixText: 'Rs. ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());

                if (value != null && value >= 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) {
      return;
    }

    if (amount < received) {
      _showMessage('Load cannot be less than the amount already received.');
      return;
    }

    await _setLoadAmount(amount);
  }

  Future<void> _setLoadAmount(int amount) async {
    setState(() {
      isLoading = true;
    });

    await widget.controller.setLoadAmount(
      customerId: widget.customerData.customerId,
      amount: amount,
    );

    await _loadReceived();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addPayment() async {
    if (loadSent <= 0) {
      _showMessage('Set load amount first.');
      return;
    }

    final controller = TextEditingController();

    final amount = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Received'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rs. ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());

                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) {
      return;
    }

    final maxAllowed = loadSent - received;

    if (amount > maxAllowed) {
      _showMessage('Payment cannot be greater than remaining amount.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    await widget.controller.addPayment(
      customerId: widget.customerData.customerId,
      amount: amount,
    );

    await _loadReceived();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendWhatsApp() async {
    try {
      await whatsappService.sendReminder(
        phone: widget.customerData.phoneNumber,
        customerName: widget.customerData.customerName,
        remainingBalance: remaining,
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Could not open WhatsApp.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // CUSTOMER HEADER
            // --------------------------------------------------
            Row(
              children: [
                Tooltip(
                  message: isDone ? 'Paid' : 'Pending',
                  child: Icon(
                    isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isDone
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFBDBDBD),
                    size: 26,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final navigator = Navigator.of(context);

                      final customer = await widget
                          .controller
                          .customerRepository
                          .getCustomerById(widget.customerData.customerId);

                      if (customer == null || !mounted) return;

                      final updated = await navigator.push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailsScreen(
                            database: widget.controller.database,
                            customer: customer,
                          ),
                        ),
                      );

                      if (updated == true && mounted) {
                        await widget.controller.loadDay(
                          widget.controller.selectedDate,
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customerData.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.customerData.phoneNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  tooltip: 'Send WhatsApp Reminder',
                  onPressed: _sendWhatsApp,
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Deactivate Customer',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Deactivate Customer'),
                        content: const Text(
                          'This customer will no longer appear in the daily list.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Deactivate'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    await widget.controller.customerRepository
                        .deactivateCustomer(widget.customerData.customerId);

                    await widget.controller.loadDay(
                      widget.controller.selectedDate,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // AMOUNTS
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isLoading ? null : _editLoadAmount,
                    child: _AmountColumn(
                      title: 'Sent',
                      amount: loadSent,
                      editable: true,
                      valueColor: const Color(0xFF37474F),
                    ),
                  ),
                ),

                Expanded(
                  child: _AmountColumn(
                    title: 'Received',
                    amount: received,
                    valueColor: const Color(0xFF2E7D32),
                  ),
                ),

                Expanded(
                  child: _AmountColumn(
                    title: 'Remaining',
                    amount: remaining,
                    valueColor: remaining > 0
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // LOAD BUTTONS
            // --------------------------------------------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Load:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(width: 8),

                  _QuickAmountButton(
                    amount: 5000,
                    onPressed: isLoading ? null : () => _setLoadAmount(5000),
                  ),

                  _QuickAmountButton(
                    amount: 10000,
                    onPressed: isLoading ? null : () => _setLoadAmount(10000),
                  ),

                  _QuickAmountButton(
                    amount: 15000,
                    onPressed: isLoading ? null : () => _setLoadAmount(15000),
                  ),

                  _QuickAmountButton(
                    amount: 20000,
                    onPressed: isLoading ? null : () => _setLoadAmount(20000),
                  ),

                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _addPayment,
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Payment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String title;
  final int amount;
  final bool editable;
  final Color? valueColor;

  const _AmountColumn({
    required this.title,
    required this.amount,
    this.editable = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rs. $amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              if (editable) ...[
                const SizedBox(width: 3),
                Icon(Icons.edit_outlined, size: 13, color: valueColor),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final VoidCallback? onPressed;

  const _QuickAmountButton({required this.amount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text('${amount ~/ 1000}K'),
      ),
    );
  }
}
