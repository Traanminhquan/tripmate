import '../../domain/entities/place.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';
import '../models/favorite_place_model.dart';

class FavoriteRepositoryImpl
    implements FavoriteRepository {
  final FavoriteRemoteDataSource
      remoteDataSource;

  FavoriteRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> addFavorite({
    required String userId,
    required Place place,
  }) {
    final model =
        FavoritePlaceModel(
      id: place.id,
      name: place.name,
      address: place.address,
      city: place.city,
      country: place.country,
      latitude: place.latitude,
      longitude: place.longitude,
      categories: place.categories,
    );

    return remoteDataSource.addFavorite(
      userId: userId,
      place: model,
    );
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String placeId,
  }) {
    return remoteDataSource.removeFavorite(
      userId: userId,
      placeId: placeId,
    );
  }

  @override
  Future<List<Place>> getFavorites(
    String userId,
  ) {
    return remoteDataSource.getFavorites(
      userId,
    );
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String placeId,
  }) {
    return remoteDataSource.isFavorite(
      userId: userId,
      placeId: placeId,
    );
  }
}