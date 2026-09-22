class ItineraryGenerationRequest {
  final String tripId;

  final double latitude;
  final double longitude;

  final DateTime startDate;
  final DateTime endDate;

  final List<String> preferences;

  final int placesPerDay;

  const ItineraryGenerationRequest({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    required this.preferences,
    this.placesPerDay = 3,
  });

  int get days =>
      endDate.difference(startDate).inDays + 1;
}