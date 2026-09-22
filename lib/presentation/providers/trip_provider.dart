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

  Future<void> updateTrip({
    required Trip trip,
    required String title,
    required String destination,
    required String country,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedTrip = Trip(
        id: trip.id,
        ownerId: trip.ownerId,
        title: title,
        destination: destination,
        country: country,
        startDate: startDate,
        endDate: endDate,
        coverImage: trip.coverImage,
        memberIds: trip.memberIds,
        createdAt: trip.createdAt,
      );

      await ref
          .read(tripRepositoryProvider)
          .updateTrip(updatedTrip);

      ref.invalidate(userTripsProvider);
      ref.invalidate(tripByIdProvider(trip.id));
    });
  }

  Future<void> addMember({
    required Trip trip,
    required String email,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final normalizedEmail =
          email.trim().toLowerCase();

      final userRepository =
          ref.read(userRepositoryProvider);

      final user =
          await userRepository
              .getUserByEmail(
        normalizedEmail,
      );

      if (user == null) {
        throw Exception(
          'User not found.',
        );
      }

      if (trip.memberIds.contains(user.id)) {
        throw Exception(
          'User is already a member of this trip.',
        );
      }

      final updatedTrip = Trip(
        id: trip.id,
        ownerId: trip.ownerId,
        title: trip.title,
        destination: trip.destination,
        country: trip.country,
        startDate: trip.startDate,
        endDate: trip.endDate,
        coverImage: trip.coverImage,
        memberIds: [
          ...trip.memberIds,
          user.id,
        ],
        createdAt: trip.createdAt,
      );

      await ref
          .read(tripRepositoryProvider)
          .updateTrip(updatedTrip);
    });

    if (!state.hasError) {
      ref.invalidate(
        tripByIdProvider(trip.id),
      );

      ref.invalidate(
        userTripsProvider,
      );
    }
  }

  Future<void> removeMember({
    required Trip trip,
    required String userId,
  }) async {
    if (userId == trip.ownerId) {
      state = AsyncError(
        Exception(
          'Trip owner cannot be removed',
        ),
        StackTrace.current,
      );

      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedMembers =
          trip.memberIds
              .where(
                (id) => id != userId,
              )
              .toList();

      final updatedTrip = Trip(
        id: trip.id,
        ownerId: trip.ownerId,
        title: trip.title,
        destination: trip.destination,
        country: trip.country,
        startDate: trip.startDate,
        endDate: trip.endDate,
        coverImage: trip.coverImage,
        memberIds: updatedMembers,
        createdAt: trip.createdAt,
      );

      await ref
          .read(tripRepositoryProvider)
          .updateTrip(updatedTrip);

      ref.invalidate(
        tripByIdProvider(trip.id),
      );

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

final tripByIdProvider =
    FutureProvider.family<Trip?, String>((ref, tripId) {
  return ref
      .read(tripRepositoryProvider)
      .getTripById(tripId);
});