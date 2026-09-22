import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
    super.country,
    super.categories,
  });

  factory PlaceModel.fromGeoapify(
    Map<String, dynamic> json,
  ) {
    final properties =
        json['properties']
                as Map<String, dynamic>? ??
            {};

    final geometry =
        json['geometry']
                as Map<String, dynamic>? ??
            {};

    final coordinates =
        geometry['coordinates']
                as List<dynamic>? ??
            [];

    final longitude =
        coordinates.isNotEmpty
            ? (coordinates[0] as num)
                .toDouble()
            : 0.0;

    final latitude =
        coordinates.length > 1
            ? (coordinates[1] as num)
                .toDouble()
            : 0.0;

    final rawCategories =
        properties['categories'];

    final categories =
        rawCategories is List
            ? rawCategories
                .map(
                  (item) =>
                      item.toString(),
                )
                .toList()
            : <String>[];

    return PlaceModel(
      id:
          properties['place_id']
              ?.toString() ??
          '',
      name:
          properties['name']
              ?.toString() ??
          properties['address_line1']
              ?.toString() ??
          'Unknown place',
      address:
          properties['formatted']
              ?.toString(),
      city:
          properties['city']
              ?.toString(),
      country:
          properties['country']
              ?.toString(),
      latitude: latitude,
      longitude: longitude,
      categories: categories,
    );
  }
}