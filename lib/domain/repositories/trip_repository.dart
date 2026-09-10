import '../entities/trip.dart';

abstract class TripRepository {
  Future<String> createTrip(Trip trip);

  Future<List<Trip>> getTripsByUser(String userId);

  Future<Trip?> getTripById(String tripId);

  Future<void> updateTrip(Trip trip);

  Future<void> deleteTrip(String tripId);
}