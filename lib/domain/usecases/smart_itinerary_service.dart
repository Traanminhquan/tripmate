import '../entities/generated_itinerary_item.dart';
import '../entities/place.dart';

class SmartItineraryService {
  List<GeneratedItineraryItem> generate({
    required List<Place> places,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> existingPlaceIds,
    int placesPerDay = 3,
  }) {
    if (places.isEmpty) {
      return [];
    }

    final days =
        endDate.difference(startDate).inDays + 1;

    final maxPlaces =
        days * placesPerDay;

    final filteredPlaces =
        places.where((place) {
      if (place.id.isEmpty) {
        return true;
      }

      return !existingPlaceIds.contains(
        place.id,
      );
    }).toList();

    final selectedPlaces =
        _removeDuplicates(
      filteredPlaces,
    ).take(maxPlaces).toList();

    final result =
        <GeneratedItineraryItem>[];

    const defaultTimes = [
      '09:00',
      '13:00',
      '17:00',
      '20:00',
    ];

    var placeIndex = 0;

    for (var day = 0;
        day < days;
        day++) {
      final date =
          startDate.add(
        Duration(days: day),
      );

      final dayPlaces = <Place>[];

      for (var i = 0;
          i < placesPerDay;
          i++) {
        if (placeIndex >=
            selectedPlaces.length) {
          break;
        }

        dayPlaces.add(
          selectedPlaces[placeIndex],
        );

        placeIndex++;
      }

      final ordered =
          _nearestNeighborOrder(
        dayPlaces,
      );

      for (var i = 0;
          i < ordered.length;
          i++) {
        result.add(
          GeneratedItineraryItem(
            place: ordered[i],
            date: date,
            startTime:
                defaultTimes[
                    i %
                        defaultTimes.length],
            order: i,
          ),
        );
      }
    }

    return result;
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

    final ordered =
        <Place>[
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