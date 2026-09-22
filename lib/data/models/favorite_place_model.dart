import '../../domain/entities/place.dart';

class FavoritePlaceModel extends Place {
  const FavoritePlaceModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
    super.country,
    super.categories,
  });

  factory FavoritePlaceModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return FavoritePlaceModel(
      id: id,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString(),
      city: map['city']?.toString(),
      country: map['country']?.toString(),
      latitude:
          (map['latitude'] as num?)?.toDouble() ??
              0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ??
              0,
      categories:
          (map['categories'] as List?)
                  ?.map(
                    (item) => item.toString(),
                  )
                  .toList() ??
              [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
    };
  }
}