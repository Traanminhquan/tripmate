import '../entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> searchCities(
    String query,
  );

  Future<List<Place>> getPlaces({
    required double latitude,
    required double longitude,
    required String category,
  });
}