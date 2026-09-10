class Trip {
  final String id;
  final String ownerId;
  final String title;
  final String destination;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverImage;
  final List<String> memberIds;
  final DateTime? createdAt;

  const Trip({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    this.coverImage,
    this.memberIds = const [],
    this.createdAt,
  });

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }
}