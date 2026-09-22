class JournalEntry {
  final String id;
  final String tripId;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final DateTime? createdAt;

  const JournalEntry({
    required this.id,
    required this.tripId,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.createdAt,
  });
}