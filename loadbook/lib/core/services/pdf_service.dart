import 'package:loadbook/models/customer_daily_data.dart';
import 'package:loadbook/models/daily_summary.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateDailyReport({
    required String businessName,
    required DateTime date,
    required List<CustomerDailyData> customers,
    required DailySummary summary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            businessName,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 8),

          pw.Text('Daily Report', style: pw.TextStyle(fontSize: 18)),

          pw.Text('${date.day}/${date.month}/${date.year}'),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            headers: const ['Shop', 'Phone', 'Load', 'Received', 'Remaining'],
            data: customers
                .map(
                  (e) => [
                    e.customerName,
                    e.phoneNumber,
                    e.loadSent.toString(),
                    e.amountReceived.toString(),
                    e.remaining.toString(),
                  ],
                )
                .toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Divider(),

          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),

          pw.Text('Todays Sell : Rs. ${summary.totalLoadSent}'),
          pw.Text('Received : Rs. ${summary.totalReceived}'),
          pw.Text('Remaining : Rs. ${summary.totalRemaining}'),
          pw.Text('Completed Customers : ${summary.completedCustomers}'),
          pw.Text('Pending Customers : ${summary.pendingCustomers}'),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
