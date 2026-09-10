class TripActivity {
  final String id;
  final String tripId;
  final String title;
  final String location;
  final DateTime date;
  final String startTime;
  final String? note;
  final int order;
  final DateTime? createdAt;

  const TripActivity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    this.note,
    required this.order,
    this.createdAt,
  });
}