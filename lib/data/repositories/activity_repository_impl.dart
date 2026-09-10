import '../../domain/entities/trip_activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_datasource.dart';
import '../models/trip_activity_model.dart';

class ActivityRepositoryImpl
    implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<String> createActivity(
    TripActivity activity,
  ) {
    final model = TripActivityModel(
      id: activity.id,
      tripId: activity.tripId,
      title: activity.title,
      location: activity.location,
      date: activity.date,
      startTime: activity.startTime,
      note: activity.note,
      order: activity.order,
      createdAt: activity.createdAt,
    );

    return remoteDataSource.createActivity(
      model,
    );
  }

  @override
  Future<List<TripActivity>> getActivities(
    String tripId,
  ) {
    return remoteDataSource.getActivities(
      tripId,
    );
  }

  @override
  Future<void> updateActivity(
    TripActivity activity,
  ) {
    final model = TripActivityModel(
      id: activity.id,
      tripId: activity.tripId,
      title: activity.title,
      location: activity.location,
      date: activity.date,
      startTime: activity.startTime,
      note: activity.note,
      order: activity.order,
      createdAt: activity.createdAt,
    );

    return remoteDataSource.updateActivity(
      model,
    );
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) {
    return remoteDataSource.deleteActivity(
      tripId: tripId,
      activityId: activityId,
    );
  }
}