class TripActivity {
  final String id;
  final String tripId;

  final String title;
  final String location;

  final DateTime date;
  final String startTime;

  final String? note;

  final int order;

  final double? latitude;
  final double? longitude;

  final String? placeId;

  final DateTime? createdAt;

  const TripActivity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.order,
    this.note,
    this.latitude,
    this.longitude,
    this.placeId,
    this.createdAt,
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null;
}