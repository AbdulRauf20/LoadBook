import 'package:drift/drift.dart';

import '../local/database.dart';

class PaymentRepository {
  final LoadBookDatabase database;

  PaymentRepository(this.database);

  Future<int> addPayment({
    required int dailyTransactionId,
    required int amount,
    required DateTime paymentDate,
  }) {
    return database
        .into(database.payments)
        .insert(
          PaymentsCompanion.insert(
            dailyTransactionId: dailyTransactionId,
            amount: amount,
            paymentDate: paymentDate,
          ),
        );
  }

  Future<List<Payment>> getPaymentsForTransaction(int dailyTransactionId) {
    return (database.select(database.payments)
          ..where(
            (payment) => payment.dailyTransactionId.equals(dailyTransactionId),
          )
          ..orderBy([
            (payment) => OrderingTerm(expression: payment.paymentDate),
          ]))
        .get();
  }

  Future<int> getTotalReceived(int dailyTransactionId) async {
    final payments = await getPaymentsForTransaction(dailyTransactionId);

    return payments.fold<int>(0, (total, payment) => total + payment.amount);
  }

  Future<int> getTotalReceivedForCustomer(int customerId) async {
    final transactions = await (database.select(
      database.dailyTransactions,
    )..where((t) => t.customerId.equals(customerId))).get();

    int total = 0;

    for (final transaction in transactions) {
      total += await getTotalReceived(transaction.id);
    }

    return total;
  }
}
