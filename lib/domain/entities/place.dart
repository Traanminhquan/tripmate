class Place {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;
  final List<String> categories;

  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.categories = const [],
  });
}