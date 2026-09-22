import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/travel_preference_mapper.dart';
import '../../domain/entities/generated_itinerary_item.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/trip.dart';
import '../../domain/usecases/smart_itinerary_service.dart';

import 'place_provider.dart';
import 'activity_provider.dart';
import '../../domain/usecases/group_preference_service.dart';
import 'user_provider.dart';
import 'trip_provider.dart';

final smartItineraryServiceProvider =
    Provider<SmartItineraryService>(
  (ref) {
    return SmartItineraryService();
  },
);

class SmartItineraryController
    extends AsyncNotifier<
        List<GeneratedItineraryItem>> {
  @override
  Future<List<GeneratedItineraryItem>>
      build() async {
    return [];
  }

  Future<void> generate({
    required Trip trip,
    required double latitude,
    required double longitude,
    int placesPerDay = 3,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        final placeRepository =
            ref.read(
          placeRepositoryProvider,
        );

        final userRepository =
            ref.read(
          userRepositoryProvider,
        );

        // =========================
        // 1. Lấy preferences của tất cả member
        // =========================

        final memberPreferences =
            <List<String>>[];

        for (final memberId
            in trip.memberIds) {
          final user =
              await userRepository.getUser(
            memberId,
          );

          if (user != null) {
            memberPreferences.add(
              user.travelPreferences,
            );
          }
        }

        // =========================
        // 2. Tính điểm preference
        // =========================

        final groupPreferenceService =
            ref.read(
          groupPreferenceServiceProvider,
        );

        final groupPreference =
            groupPreferenceService.calculate(
          memberPreferences:
              memberPreferences,
        );

        // =========================
        // 3. Convert preference
        //    → Geoapify categories
        //    + score
        // =========================

        final categoryScores =
            <String, int>{};

        for (final entry
            in groupPreference
                .scores.entries) {
          final categories =
              TravelPreferenceMapper
                  .toCategories(
            [
              entry.key,
            ],
          );

          for (final category
              in categories) {
            categoryScores.update(
              category,
              (value) =>
                  value + entry.value,
              ifAbsent:
                  () => entry.value,
            );
          }
        }

        // =========================
        // 4. Fallback nếu không
        //    member nào có preference
        // =========================

        if (categoryScores.isEmpty) {
          final defaultCategories =
              TravelPreferenceMapper
                  .toCategories(
            const [],
          );

          for (final category
              in defaultCategories) {
            categoryScores[
              category
            ] = 1;
          }
        }

        debugPrint(
          'GROUP PREFERENCES: '
          '${groupPreference.scores}',
        );

        debugPrint(
          'CATEGORY SCORES: '
          '$categoryScores',
        );

        // =========================
        // 5. Query Places
        //    mỗi category đúng 1 lần
        // =========================

        final placesByCategory =
            <String, List<Place>>{};

        for (final category
            in categoryScores.keys) {
          try {
            final places =
                await placeRepository
                    .getPlaces(
              latitude: latitude,
              longitude: longitude,
              category: category,
            );

            if (places.isNotEmpty) {
              placesByCategory[
                category
              ] = places;
            }
          } catch (error) {
            debugPrint(
              'CATEGORY ERROR '
              '$category: $error',
            );
          }
        }

        // =========================
        // 6. Trộn places dựa trên
        //    trọng số preference
        // =========================

        final allPlaces =
            <Place>[];

        final categoryIndexes =
            <String, int>{
          for (final category
              in placesByCategory.keys)
            category: 0,
        };

        var addedSomething = true;

        while (addedSomething) {
          addedSomething = false;

          final orderedCategories =
              placesByCategory
                  .keys
                  .toList()
                ..sort(
                  (a, b) {
                    return (categoryScores[
                                b] ??
                            0)
                        .compareTo(
                      categoryScores[a] ??
                          0,
                    );
                  },
                );

          for (final category
              in orderedCategories) {
            final weight =
                categoryScores[
                        category] ??
                    1;

            final places =
                placesByCategory[
                    category]!;

            for (var i = 0;
                i < weight;
                i++) {
              final index =
                  categoryIndexes[
                      category]!;

              if (index <
                  places.length) {
                allPlaces.add(
                  places[index],
                );

                categoryIndexes[
                  category
                ] = index + 1;

                addedSomething = true;
              }
            }
          }
        }

        // =========================
        // 7. Lấy activity hiện có
        //    để tránh duplicate
        // =========================

        final existingActivities =
            await ref.read(
          activitiesProvider(
            trip.id,
          ).future,
        );

        final existingPlaceIds =
            existingActivities
                .map(
                  (activity) =>
                      activity.placeId,
                )
                .whereType<String>()
                .where(
                  (id) => id.isNotEmpty,
                )
                .toList();

        // =========================
        // 8. Generate itinerary
        // =========================

        final service =
            ref.read(
          smartItineraryServiceProvider,
        );

       return service.generate(
          places: allPlaces,
          startDate:
              trip.startDate,
          endDate:
              trip.endDate,
          existingPlaceIds:
              existingPlaceIds,
          existingActivities:
              existingActivities,
          placesPerDay:
              placesPerDay,
        );
      },
    );
  }

  void clear() {
    state =
        const AsyncData([]);
  }
}

final smartItineraryControllerProvider =
    AsyncNotifierProvider<
        SmartItineraryController,
        List<GeneratedItineraryItem>>(
  SmartItineraryController.new,
);

final groupPreferenceServiceProvider =
    Provider<GroupPreferenceService>(
  (ref) {
    return GroupPreferenceService();
  },
);

final tripGroupPreferencesProvider =
    FutureProvider.family<
        GroupPreferenceResult,
        String>(
  (ref, tripId) async {
    final trip =
        await ref.watch(
      tripByIdProvider(
        tripId,
      ).future,
    );

    if (trip == null) {
      return const GroupPreferenceResult(
        scores: {},
        rankedPreferences: [],
      );
    }

    final repository =
        ref.read(
      userRepositoryProvider,
    );

    final memberPreferences =
        <List<String>>[];

    for (final memberId
        in trip.memberIds) {
      final user =
          await repository.getUser(
        memberId,
      );

      if (user != null) {
        memberPreferences.add(
          user.travelPreferences,
        );
      }
    }

    return ref
        .read(
          groupPreferenceServiceProvider,
        )
        .calculate(
          memberPreferences:
              memberPreferences,
        );
  },
);