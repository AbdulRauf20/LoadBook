class CustomerDailyData {
  final int customerId;
  final int transactionId;

  final String customerName;
  final String phoneNumber;

  final int loadSent;
  final int amountReceived;
  final int remaining;

  final bool isCompleted;

  const CustomerDailyData({
    required this.customerId,
    required this.transactionId,
    required this.customerName,
    required this.phoneNumber,
    required this.loadSent,
    required this.amountReceived,
    required this.remaining,
    required this.isCompleted,
  });

  CustomerDailyData copyWith({
    int? loadSent,
    int? amountReceived,
    int? remaining,
    bool? isCompleted,
  }) {
    return CustomerDailyData(
      customerId: customerId,
      transactionId: transactionId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      loadSent: loadSent ?? this.loadSent,
      amountReceived: amountReceived ?? this.amountReceived,
      remaining: remaining ?? this.remaining,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
