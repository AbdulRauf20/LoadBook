import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            DailyHeader(
              date: controller.selectedDate,
              onPreviousDay: controller.previousDay,
              onNextDay: controller.nextDay,
            ),

            SummaryCards(controller: controller),

            Expanded(child: CustomerTable(controller: controller)),
          ],
        ),
      ),
    );
  }
}
