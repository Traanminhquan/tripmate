class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final DateTime date;
  final List<String> splitBetween;
  final String? note;
  final DateTime? createdAt;

  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.date,
    required this.splitBetween,
    this.note,
    this.createdAt,
  });

  double get amountPerPerson {
    if (splitBetween.isEmpty) {
      return amount;
    }

    return amount / splitBetween.length;
  }
}