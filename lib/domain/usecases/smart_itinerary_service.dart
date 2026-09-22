import '../entities/generated_itinerary_item.dart';
import '../entities/place.dart';
import '../entities/trip_activity.dart';

class SmartItineraryService {
  static const List<String> _defaultTimes = [
    '09:00',
    '13:00',
    '17:00',
    '20:00',
  ];

  List<GeneratedItineraryItem> generate({
    required List<Place> places,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> existingPlaceIds,
    required List<TripActivity> existingActivities,
    int placesPerDay = 3,
  }) {
    if (places.isEmpty) {
      return [];
    }

    final days =
        endDate.difference(startDate).inDays + 1;

    final filteredPlaces = places.where(
      (place) {
        if (place.id.isEmpty) {
          return true;
        }

        return !existingPlaceIds.contains(
          place.id,
        );
      },
    ).toList();

    final uniquePlaces =
        _removeDuplicates(
      filteredPlaces,
    );

    if (uniquePlaces.isEmpty) {
      return [];
    }

    final dayPlans = <_DayPlan>[];

    for (var dayIndex = 0;
        dayIndex < days;
        dayIndex++) {
      final date = startDate.add(
        Duration(days: dayIndex),
      );

      final activitiesForDay =
          existingActivities.where(
        (activity) =>
            _sameDay(
          activity.date,
          date,
        ),
      ).toList();

      final remainingSlots =
          placesPerDay -
              activitiesForDay.length;

      final availableTimes =
          remainingSlots <= 0
              ? <String>[]
              : _defaultTimes
                  .where(
                    (time) =>
                        !_hasTimeConflict(
                      time,
                      activitiesForDay,
                    ),
                  )
                  .take(
                    remainingSlots,
                  )
                  .toList();

      dayPlans.add(
        _DayPlan(
          date: date,
          existingCount:
              activitiesForDay.length,
          availableTimes:
              availableTimes,
        ),
      );
    }

    // Ngày ít activity hơn được ưu tiên trước.
    dayPlans.sort(
      (a, b) {
        final countCompare =
            a.existingCount.compareTo(
          b.existingCount,
        );

        if (countCompare != 0) {
          return countCompare;
        }

        return a.date.compareTo(
          b.date,
        );
      },
    );

    final result =
        <GeneratedItineraryItem>[];

    var placeIndex = 0;

    for (final plan in dayPlans) {
      if (placeIndex >=
          uniquePlaces.length) {
        break;
      }

      if (plan.availableTimes.isEmpty) {
        continue;
      }

      final remainingCount =
          uniquePlaces.length -
              placeIndex;

      final amountForDay =
          remainingCount <
                  plan.availableTimes.length
              ? remainingCount
              : plan.availableTimes.length;

      final dayPlaces =
          uniquePlaces.sublist(
        placeIndex,
        placeIndex + amountForDay,
      );

      final orderedPlaces =
          _nearestNeighborOrder(
        dayPlaces,
      );

      for (var i = 0;
          i < orderedPlaces.length;
          i++) {
        result.add(
          GeneratedItineraryItem(
            place:
                orderedPlaces[i],
            date:
                plan.date,
            startTime:
                plan.availableTimes[i],
            order:
                plan.existingCount + i,
          ),
        );
      }

      placeIndex +=
          orderedPlaces.length;
    }

    // Sau khi ưu tiên ngày ít activity,
    // sort lại preview theo ngày + thời gian.
    result.sort(
      (a, b) {
        final dateCompare =
            a.date.compareTo(
          b.date,
        );

        if (dateCompare != 0) {
          return dateCompare;
        }

        return a.startTime.compareTo(
          b.startTime,
        );
      },
    );

    return result;
  }

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _hasTimeConflict(
    String candidate,
    List<TripActivity> activities,
  ) {
    final candidateMinutes =
        _timeToMinutes(
      candidate,
    );

    for (final activity
        in activities) {
      final existingMinutes =
          _timeToMinutes(
        activity.startTime,
      );

      final difference =
          (candidateMinutes -
                  existingMinutes)
              .abs();

      if (difference < 120) {
        return true;
      }
    }

    return false;
  }

  int _timeToMinutes(
    String time,
  ) {
    final parts =
        time.split(':');

    if (parts.length != 2) {
      return 0;
    }

    final hour =
        int.tryParse(
          parts[0],
        ) ??
        0;

    final minute =
        int.tryParse(
          parts[1],
        ) ??
        0;

    return hour * 60 + minute;
  }

  List<Place> _removeDuplicates(
    List<Place> places,
  ) {
    final seen = <String>{};
    final result = <Place>[];

    for (final place in places) {
      final key =
          place.id.isNotEmpty
              ? place.id
              : '${place.latitude}_${place.longitude}';

      if (seen.add(key)) {
        result.add(place);
      }
    }

    return result;
  }

  List<Place> _nearestNeighborOrder(
    List<Place> places,
  ) {
    if (places.length <= 2) {
      return places;
    }

    final remaining =
        List<Place>.from(
      places,
    );

    final ordered = <Place>[
      remaining.removeAt(0),
    ];

    while (remaining.isNotEmpty) {
      final current =
          ordered.last;

      remaining.sort(
        (a, b) {
          final distanceA =
              _distanceSquared(
            current.latitude,
            current.longitude,
            a.latitude,
            a.longitude,
          );

          final distanceB =
              _distanceSquared(
            current.latitude,
            current.longitude,
            b.latitude,
            b.longitude,
          );

          return distanceA.compareTo(
            distanceB,
          );
        },
      );

      ordered.add(
        remaining.removeAt(0),
      );
    }

    return ordered;
  }

  double _distanceSquared(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat =
        lat1 - lat2;

    final dLon =
        lon1 - lon2;

    return dLat * dLat +
        dLon * dLon;
  }
}

class _DayPlan {
  final DateTime date;
  final int existingCount;
  final List<String> availableTimes;

  const _DayPlan({
    required this.date,
    required this.existingCount,
    required this.availableTimes,
  });
}