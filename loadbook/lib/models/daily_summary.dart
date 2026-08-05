class DailySummary {
  final int totalLoadSent;
  final int totalReceived;
  final int totalRemaining;
  final int completedCustomers;
  final int pendingCustomers;

  const DailySummary({
    required this.totalLoadSent,
    required this.totalReceived,
    required this.totalRemaining,
    required this.completedCustomers,
    required this.pendingCustomers,
  });

  int get totalCustomers => completedCustomers + pendingCustomers;
}
