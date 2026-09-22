import '../../domain/entities/place.dart';
import '../../domain/repositories/place_repository.dart';
import '../datasources/place_remote_datasource.dart';

class PlaceRepositoryImpl
    implements PlaceRepository {
  final PlaceRemoteDataSource
      remoteDataSource;

  PlaceRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Place>> searchCities(
    String query,
  ) {
    return remoteDataSource.searchCities(
      query,
    );
  }

  @override
  Future<List<Place>> getPlaces({
    required double latitude,
    required double longitude,
    required String category,
  }) {
    return remoteDataSource.getPlaces(
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }
}