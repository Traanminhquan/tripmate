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
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final activities = await ref
          .read(activityRepositoryProvider)
          .getActivities(tripId);

      final activitiesForDate = activities
          .where(
            (activity) =>
                _sameDate(
              activity.date,
              date,
            ),
          )
          .toList();

      final activity = TripActivity(
        id: '',
        tripId: tripId,
        title: title,
        location: location,
        date: date,
        startTime: startTime,
        note: note,
        order: activitiesForDate.length,
      );

      await ref
          .read(activityRepositoryProvider)
          .createActivity(activity);

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