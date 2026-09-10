import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

final tripRemoteDataSourceProvider =
    Provider<TripRemoteDataSource>((ref) {
  return TripRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

final tripRepositoryProvider =
    Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    remoteDataSource:
        ref.read(tripRemoteDataSourceProvider),
  );
});

final userTripsProvider =
    FutureProvider<List<Trip>>((ref) async {
  final firebaseAuth =
      ref.watch(firebaseAuthProvider);

  final user = firebaseAuth.currentUser;

  if (user == null) {
    return [];
  }

  return ref
      .read(tripRepositoryProvider)
      .getTripsByUser(user.uid);
});

class TripController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createTrip({
    required String title,
    required String destination,
    required String country,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = ref
        .read(firebaseAuthProvider)
        .currentUser;

    if (user == null) {
      state = AsyncError(
        Exception('User is not logged in'),
        StackTrace.current,
      );

      return null;
    }

    state = const AsyncLoading();

    String? tripId;

    state = await AsyncValue.guard(() async {
      final trip = Trip(
        id: '',
        ownerId: user.uid,
        title: title,
        destination: destination,
        country: country,
        startDate: startDate,
        endDate: endDate,
        memberIds: [
          user.uid,
        ],
      );

      tripId = await ref
          .read(tripRepositoryProvider)
          .createTrip(trip);

      ref.invalidate(
        userTripsProvider,
      );
    });

    return tripId;
  }

  Future<void> deleteTrip(
    String tripId,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(tripRepositoryProvider)
          .deleteTrip(tripId);

      ref.invalidate(
        userTripsProvider,
      );
    });
  }
}

final tripControllerProvider =
    AsyncNotifierProvider<
        TripController,
        void>(
  TripController.new,
);