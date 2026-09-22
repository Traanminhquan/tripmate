class Settlement {
  final String fromUserId;
  final String toUserId;
  final double amount;

  const Settlement({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });
}