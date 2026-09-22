import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/activity_remote_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/entities/trip_activity.dart';
import '../../domain/repositories/activity_repository.dart';
import 'user_provider.dart';

final activityRemoteDataSourceProvider =
    Provider<ActivityRemoteDataSource>((ref) {
  return ActivityRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

final activityRepositoryProvider =
    Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(
    remoteDataSource:
        ref.read(activityRemoteDataSourceProvider),
  );
});

final activitiesProvider =
    FutureProvider.family<
        List<TripActivity>,
        String>(
  (ref, tripId) {
    return ref
        .read(activityRepositoryProvider)
        .getActivities(tripId);
  },
);

class ActivityController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createActivity({
    required String tripId,
    required String title,
    required String location,
    required DateTime date,
    required String startTime,
    String? note,
    double? latitude,
    double? longitude,
    String? placeId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final existingActivities =
          await ref.read(
        activitiesProvider(tripId).future,
      );

      final sameDayActivities =
          existingActivities.where(
        (activity) {
          return activity.date.year ==
                  date.year &&
              activity.date.month ==
                  date.month &&
              activity.date.day ==
                  date.day;
        },
      ).toList();

      final activity = TripActivity(
        id: '',
        tripId: tripId,
        title: title,
        location: location,
        date: date,
        startTime: startTime,
        note: note,
        order: sameDayActivities.length,

        latitude: latitude,
        longitude: longitude,
        placeId: placeId,
      );

      await ref
          .read(
            activityRepositoryProvider,
          )
          .createActivity(
            activity,
          );

      ref.invalidate(
        activitiesProvider(tripId),
      );
    });
  }

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(activityRepositoryProvider)
          .deleteActivity(
            tripId: tripId,
            activityId: activityId,
          );

      ref.invalidate(
        activitiesProvider(tripId),
      );
    });
  }

  Future<void> updateActivity({
    required TripActivity activity,
    required String title,
    required String location,
    required DateTime date,
    required String startTime,
    String? note,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedActivity = TripActivity(
        id: activity.id,
        tripId: activity.tripId,
        title: title,
        location: location,
        date: date,
        startTime: startTime,
        note: note,
        order: activity.order,
        latitude: activity.latitude,
        longitude: activity.longitude,
        placeId: activity.placeId,
        createdAt: activity.createdAt,
      );

      await ref
          .read(activityRepositoryProvider)
          .updateActivity(updatedActivity);

      ref.invalidate(
        activitiesProvider(activity.tripId),
      );

      ref.invalidate(
        activityByIdProvider(
          (
            tripId: activity.tripId,
            activityId: activity.id,
          ),
        ),
      );
    });
  }

  Future<void> reorderActivities({
    required String tripId,
    required List<TripActivity> activities,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final reorderedActivities =
          <TripActivity>[];

      for (int i = 0; i < activities.length; i++) {
        final activity = activities[i];

        reorderedActivities.add(
          TripActivity(
            id: activity.id,
            tripId: activity.tripId,
            title: activity.title,
            location: activity.location,
            date: activity.date,
            startTime: activity.startTime,
            note: activity.note,
            order: i,
            createdAt: activity.createdAt,
          ),
        );
      }

      await ref
          .read(activityRepositoryProvider)
          .updateActivityOrder(
            tripId: tripId,
            activities: reorderedActivities,
          );

      ref.invalidate(
        activitiesProvider(tripId),
      );
    });
  }
  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

final activityControllerProvider =
    AsyncNotifierProvider<
        ActivityController,
        void>(
  ActivityController.new,
);

final activityByIdProvider =
    FutureProvider.family<
        TripActivity?,
        ({String tripId, String activityId})>(
  (ref, params) async {
    final activities = await ref
        .read(activityRepositoryProvider)
        .getActivities(params.tripId);

    for (final activity in activities) {
      if (activity.id == params.activityId) {
        return activity;
      }
    }

    return null;
  },
);