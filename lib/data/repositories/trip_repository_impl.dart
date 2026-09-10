import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<String> createTrip(
    Trip trip,
  ) {
    final model = TripModel(
      id: trip.id,
      ownerId: trip.ownerId,
      title: trip.title,
      destination: trip.destination,
      country: trip.country,
      startDate: trip.startDate,
      endDate: trip.endDate,
      coverImage: trip.coverImage,
      memberIds: trip.memberIds,
      createdAt: trip.createdAt,
    );

    return remoteDataSource.createTrip(model);
  }

  @override
  Future<List<Trip>> getTripsByUser(
    String userId,
  ) {
    return remoteDataSource.getTripsByUser(
      userId,
    );
  }

  @override
  Future<Trip?> getTripById(
    String tripId,
  ) {
    return remoteDataSource.getTripById(
      tripId,
    );
  }

  @override
  Future<void> updateTrip(
    Trip trip,
  ) {
    final model = TripModel(
      id: trip.id,
      ownerId: trip.ownerId,
      title: trip.title,
      destination: trip.destination,
      country: trip.country,
      startDate: trip.startDate,
      endDate: trip.endDate,
      coverImage: trip.coverImage,
      memberIds: trip.memberIds,
      createdAt: trip.createdAt,
    );

    return remoteDataSource.updateTrip(
      model,
    );
  }

  @override
  Future<void> deleteTrip(
    String tripId,
  ) {
    return remoteDataSource.deleteTrip(
      tripId,
    );
  }
}