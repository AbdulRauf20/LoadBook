import 'package:flutter/foundation.dart';
import 'package:loadbook/data/repositories/daily_balance_repository.dart';
import 'package:loadbook/models/customer_daily_data.dart';
import 'package:loadbook/models/daily_summary.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class DailyController extends ChangeNotifier {
  final LoadBookDatabase database;
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;
  final PaymentRepository paymentRepository;
  final DailyBalanceRepository dailyBalanceRepository;

  DailyController(this.database)
    : customerRepository = CustomerRepository(database),
      transactionRepository = TransactionRepository(database),
      paymentRepository = PaymentRepository(database),
      dailyBalanceRepository = DailyBalanceRepository(database);

  DateTime selectedDate = DateTime.now();
  int openingBalance = 0;
  int closingBalance = 0;

  List<Customer> customers = [];
  List<DailyTransaction> transactions = [];
  List<CustomerDailyData> customerDailyData = [];

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadDay(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      customers = await customerRepository.getActiveCustomers();

      transactions = await transactionRepository.getTransactionsForDate(
        selectedDate,
      );
      await _loadDailyBalance();
      await _buildCustomerDailyData();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DailyTransaction> getOrCreateTransaction(int customerId) async {
    final existing = await transactionRepository.getTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    if (existing != null) {
      return existing;
    }

    await transactionRepository.createDailyTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    final transaction = await transactionRepository.getTransaction(
      customerId: customerId,
      date: selectedDate,
    );

    if (transaction == null) {
      throw Exception('Failed to create daily transaction.');
    }

    return transaction;
  }

  Future<void> setLoadAmount({
    required int customerId,
    required int amount,
  }) async {
    final transaction = await getOrCreateTransaction(customerId);

    await transactionRepository.updateLoadSent(
      transactionId: transaction.id,
      loadAmount: amount,
    );

    await _updateClosingBalance();
    await loadDay(selectedDate);
  }

  Future<void> addPayment({
    required int customerId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    final transaction = await getOrCreateTransaction(customerId);

    await paymentRepository.addPayment(
      dailyTransactionId: transaction.id,
      amount: amount,
      paymentDate: DateTime.now(),
    );

    await _updateClosingBalance();
    await loadDay(selectedDate);
  }

  Future<int> getAmountReceived(int transactionId) {
    return paymentRepository.getTotalReceived(transactionId);
  }

  Future<int> getRemainingAmount(DailyTransaction transaction) async {
    final received = await getAmountReceived(transaction.id);

    final remaining = transaction.loadSent - received;

    return remaining < 0 ? 0 : remaining;
  }

  Future<void> nextDay() async {
    await loadDay(selectedDate.add(const Duration(days: 1)));
  }

  Future<void> previousDay() async {
    await loadDay(selectedDate.subtract(const Duration(days: 1)));
  }

  Future<DailySummary> getDailySummary() async {
    int totalLoadSent = 0;
    int totalReceived = 0;
    int completedCustomers = 0;
    int pendingCustomers = 0;

    for (final transaction in transactions) {
      totalLoadSent += transaction.loadSent;

      final received = await getAmountReceived(transaction.id);

      totalReceived += received;

      final remaining = transaction.loadSent - received;

      if (transaction.loadSent > 0 && remaining <= 0) {
        completedCustomers++;
      } else if (transaction.loadSent > 0) {
        pendingCustomers++;
      }
    }

    return DailySummary(
      totalLoadSent: totalLoadSent,
      totalReceived: totalReceived,
      totalRemaining: (totalLoadSent - totalReceived).clamp(0, totalLoadSent),
      completedCustomers: completedCustomers,
      pendingCustomers: pendingCustomers,
    );
  }

  Future<void> _loadDailyBalance() async {
    var balance = await dailyBalanceRepository.getBalanceForDate(selectedDate);

    if (balance == null) {
      final previousClosing = await dailyBalanceRepository
          .getPreviousClosingBalance(selectedDate);

      await dailyBalanceRepository.createDailyBalance(
        date: selectedDate,
        openingBalance: previousClosing,
      );

      balance = await dailyBalanceRepository.getBalanceForDate(selectedDate);
    }

    openingBalance = balance!.openingBalance;
    closingBalance = balance.closingBalance;
  }

  Future<void> _updateClosingBalance() async {
    final summary = await getDailySummary();

    closingBalance =
        openingBalance + summary.totalReceived - summary.totalLoadSent;

    await dailyBalanceRepository.updateClosingBalance(
      date: selectedDate,
      closingBalance: closingBalance,
    );
  }

  Future<void> _buildCustomerDailyData() async {
    customerDailyData.clear();

    for (final customer in customers) {
      final transaction = await getOrCreateTransaction(customer.id);

      final amountReceived = await getAmountReceived(transaction.id);

      final remaining = (transaction.loadSent - amountReceived).clamp(
        0,
        transaction.loadSent,
      );

      customerDailyData.add(
        CustomerDailyData(
          customerId: customer.id,
          transactionId: transaction.id,
          customerName: customer.name,
          phoneNumber: customer.phoneNumber,
          loadSent: transaction.loadSent,
          amountReceived: amountReceived,
          remaining: remaining,
          isCompleted: transaction.loadSent > 0 && remaining == 0,
        ),
      );
    }
  }
}
