import 'package:flutter/material.dart';
import 'package:loadbook/core/services/pdf_service.dart';
import 'package:loadbook/features/customers/screens/add_customer_screen.dart';
import '../widgets/balance_card.dart';
import '../../../app/theme.dart';
import '../../../data/local/database.dart';
import '../controllers/daily_controller.dart';
import '../widgets/daily_header.dart';
import '../widgets/summary_cards.dart';
import '../widgets/customer_table.dart';

class DailyScreen extends StatefulWidget {
  final LoadBookDatabase database;

  const DailyScreen({super.key, required this.database});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final pdfService = PdfService();
  late final DailyController controller;

  @override
  void initState() {
    super.initState();

    controller = DailyController(widget.database);

    controller.loadDay(DateTime.now());
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text('LoadBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download Report',
            onPressed: () async {
              final summary = await controller.getDailySummary();

              await pdfService.generateDailyReport(
                businessName: 'LoadBook',
                date: controller.selectedDate,
                customers: controller.customerDailyData,
                summary: summary,
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(database: widget.database),
            ),
          );

          if (added == true) {
            await controller.loadDay(controller.selectedDate);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DailyHeader(
              date: controller.selectedDate,
              onPreviousDay: controller.previousDay,
              onNextDay: controller.nextDay,
            ),

            SummaryCards(controller: controller),

            BalanceCard(
              openingBalance: controller.openingBalance,
              closingBalance: controller.closingBalance,
            ),

            Expanded(child: CustomerTable(controller: controller)),
          ],
        ),
      ),
    );
  }
}
