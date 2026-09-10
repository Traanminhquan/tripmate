import '../entities/trip_activity.dart';

abstract class ActivityRepository {
  Future<String> createActivity(
    TripActivity activity,
  );

  Future<List<TripActivity>> getActivities(
    String tripId,
  );

  Future<void> updateActivity(
    TripActivity activity,
  );

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  });

  Future<void> updateActivityOrder({
    required String tripId,
    required List<TripActivity> activities,
  });
}