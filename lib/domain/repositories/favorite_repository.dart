import '../entities/place.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite({
    required String userId,
    required Place place,
  });

  Future<void> removeFavorite({
    required String userId,
    required String placeId,
  });

  Future<List<Place>> getFavorites(
    String userId,
  );

  Future<bool> isFavorite({
    required String userId,
    required String placeId,
  });
}